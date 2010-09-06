class Artist < ActiveRecord::Base
  validates_presence_of :name
  validates_numericality_of :refer_count, :fetch_count
  
  LAST_FM_API_KEY = "25c1d3e948b977d8893a92467d647a21"
  LAST_FM_BASE_URL = "http://ws.audioscrobbler.com/2.0/?"
  TINYSONG_BASE_URL = "http://tinysong.com/b/"
  UPDATE_TIME = 4.weeks

  # updates artist data using lastFM and grooveshark
  def fetch
    ### UPDATE META DATA
    self.data = open("#{LAST_FM_BASE_URL}method=artist.getInfo&api_key=#{LAST_FM_API_KEY}&artist=#{self.to_lastFM.to_url}&format=json").read
    data = open("#{LAST_FM_BASE_URL}method=artist.getTopTracks&api_key=#{LAST_FM_API_KEY}&artist=#{self.to_lastFM.to_url}&format=json").read
    self.fetch_count = self.fetch_count + 1
    self.last_fetch_at = Time.now

    ### UPDATE SONGS
    code = song_data = ""
    JSON.parse(data)['toptracks']['track'].each do |track|
      begin
        track_name = strip_symbols(track['name']).to_url
        song_data = JSON.parse(open("#{TINYSONG_BASE_URL}#{track_name}+#{self.name}?format=json").read)
        code << song_data['SongID'].to_s + "," unless song_data == []
        rescue Timeout::Error
          next
      end
    end
    self.shark_code = code

    ### UPDATE SIMILAR ARTISTS
    self.similar_data = open("#{LAST_FM_BASE_URL}method=artist.getsimilar&api_key=#{LAST_FM_API_KEY}&artist=#{self.to_lastFM.to_url}&format=json").read unless self.similar_data.present?
    Delayed::Job.enqueue(SimilarArtistWorker.new(self.id), 1, Time.now) if self.queue_similar?
    
    self.dequeue
    save
  end
  
  # returns all needed model data for page
  def get_data
    self.refer_count = self.refer_count + 1
    save
    return {:data => self.data, :code => self.shark_code, :similar => self.similar_data}
  end
  
  # queues all similar artists to be loaded
  def queue_similar_artists
    JSON.parse(self.similar_data)['similarartists']['artist'].each do |sim_artist|
      begin
        lookup_data = JSON.parse(open("#{TINYSONG_BASE_URL}#{strip_symbols(sim_artist['name']).to_url}?format=json").read)
        unless lookup_data == []
          queued_artist = Artist.find_or_create_by_name(lookup_data['ArtistName'].to_url)
          queued_artist.enqueue
        end
        rescue URI::InvalidURIError
          next
      end
    end
    self.queue_similar = false
    save
  end
  
  # queues an artist to be updated based on several conditions
  def enqueue(override = false)
    if self.job_id.nil? && !(self.last_fetch_at.present? && (Time.now - self.last_fetch_at) < UPDATE_TIME) && !override
      Delayed::Job.enqueue(ArtistWorker.new(self.id), 0, Time.now)
      self.job_id = Delayed::Job.last.id
      save
    end    
  end
  
  # since Delayed::Job is not an activerecord model
  # return an artists delayed job record
  def job
    return nil if self.job_id.nil?
    Delayed::Job.find(self.job_id)
  end

protected

  # returns artist name formatted for lastFM
  def to_lastFM
    part = self.name.split('+')
    part[0] = "" if part[0].downcase == "the"
    return part.join('+').titlecase
  end
  
  # removes artist from update queue
  def dequeue
    self.job.destroy if self.job.present?
    self.job_id = nil
  end
  
  # strip all symbols from a song title when doing tinysong lookups
  def strip_symbols(name)
    return name.to_s.gsub(/[[:punct:]]/, '')
  end

end