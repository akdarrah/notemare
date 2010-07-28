class Artist < ActiveRecord::Base
  validates_presence_of :name
  validates_numericality_of :refer_count, :fetch_count

  # updates artist data using lastFM and grooveshark
  def fetch
    ### UPDATE META DATA
    self.source_url = "http://ws.audioscrobbler.com/2.0/?method=artist.getTopTracks&api_key=25c1d3e948b977d8893a92467d647a21&artist=" + self.to_lastFM.to_url + "&format=json" if self.source_url.nil?
    self.data = open("http://ws.audioscrobbler.com/2.0/?method=artist.getInfo&api_key=25c1d3e948b977d8893a92467d647a21&artist=" + self.to_lastFM.to_url + "&format=json").read
    data = open(self.source_url).read
    self.fetch_count = self.fetch_count + 1
    self.last_fetch_at = Time.now

    ### UPDATE SONGS
    code = song_data = ""
    JSON.parse(data)['toptracks']['track'].each do |track|
      begin
        track_name = strip_song(track['name']).to_url
        song_data = JSON.parse(open("http://tinysong.com/b/" + track_name + "+" + self.name + "?format=json").read)
        code << song_data['SongID'].to_s + "," unless song_data == []
        rescue Timeout::Error
          next
      end
    end
    self.shark_code = code

    ### UPDATE SIMILAR ARTISTS
    self.similar_data = open("http://ws.audioscrobbler.com/2.0/?method=artist.getsimilar&artist=" + self.name.to_url + "&api_key=25c1d3e948b977d8893a92467d647a21&format=json").read
    save
  end
  
  # returns all needed model data for page
  def get_data
    self.refer_count = self.refer_count + 1
    save
    return {:data => self.data, :code => self.shark_code, :similar => self.similar_data}
  end
  
  # Queues ArtistWorker Delayed Job if data is more than 1 week old
  def expired?
    Delayed::Job.enqueue ArtistWorker.new(self.id) if (Time.now - self.last_fetch_at) > 1.week
  end

protected

  # returns artist name formatted for lastFM
  def to_lastFM
    part = self.name.split('+')
    part[0] = "" if part[0].downcase == "the"
    return part.join('+').titlecase
  end
  
  # strip all symbols from a song title when doing tinysong lookups
  def strip_song(name)
    return name.to_s.gsub(/[[:punct:]]/, '')
  end

end