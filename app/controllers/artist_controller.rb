class ArtistController < ApplicationController
  
  # CURRENT
  # ##################################################
  # FEATURE:: add 'Mix' model for saving playlists
  # FEATURE:: add embed code into site and share links
  # FEATURE:: inline application helpers (front page content)
  # FEATURE:: throw an error when artist not found
  # CHORE:: automate database backups

  # FOR PRODUCTION DEPLOY
  # ##################################################
  # 1. write meta data and submit to search engines
  # 2. submit to facebook and tweet
  # 3. submit to reddit (and later digg)
  
  # POST DEPLOY
  # ##################################################
  # FEATURE:: make artist preview better
  # FEATURE:: make update time dynamic
  # FEATURE:: email summary
    
  layout 'base.html.haml'
  
  def index
  end
  
  def songs
    # get all artists user has entered
    artists = params[:artist][:name].split(',')
    @code = ""
    @data = {}
    
    if artists.length == 1
      # determine whether to randomize the results or not
      # if user inserted a ! into input, remove it
      rand = true if artists[0][-1,1] == '!'
      artists[0] = artists[0].split("!")[0] if rand
      
      # determine whether to include similar artists
      # if user inserted a ? into input, remove it
      sim = true if artists[0][-1,1] == '?'
      artists[0] = artists[0].split("?")[0] if sim
      
      # if sim is true, we need to append similar artists to artists array before looping
      # this requires an additional tinysong and Artist lookup to do
      # THIS SUCKS -> REFACTOR IF POSSIBLE
      if sim == true
        base_artist = Artist.find_by_name(artists[0].to_url)
        lookup_data = JSON.parse(open("#{Artist::TINYSONG_BASE_URL}#{artists[0].to_url}?format=json").read) if base_artist.nil?
        unless lookup_data == []
          base_artist ||= Artist.find_or_create_by_name(lookup_data['ArtistName'].to_url)
          base_artist.enqueue(base_artist.shark_code.present? ? false : true)
          base_artist.fetch if base_artist.data.nil? || base_artist.similar_data.nil? || base_artist.shark_code.nil?
          JSON.parse(base_artist.similar_data)['similarartists']['artist'][0..2].each do |sa|
            artists << sa['name']
          end
        end
      end
    end
            
    # loop through each artist given and compile a string of all shark codes
    artists.each do |instance|
      @artist = Artist.find_by_name(instance.to_url)
      lookup_data = JSON.parse(open("#{Artist::TINYSONG_BASE_URL}#{instance.to_url}?format=json").read) if @artist.nil?
      # if lookup_data is an empty set you do not have a valid artist
      unless lookup_data == []
        @artist ||= Artist.find_or_create_by_name(lookup_data['ArtistName'].to_url)
        @artist.enqueue(@artist.shark_code.present? ? false : true)
        @artist.fetch if @artist.data.nil? || @artist.similar_data.nil? || @artist.shark_code.nil?
        artist_data = @artist.get_data
        @code << artist_data[:code]
        artist = JSON.parse(artist_data[:data])
        @data[artist['artist']['name']] = {:name => artist['artist']['name'], :amazon_link_name => artist['artist']['name'].to_url, :image => artist['artist']['image'][1]['#text'], :lastFM => artist['artist']['url']}
      end
    end
    # respond to request after all artists have been iterated
    @code = randomize(@code) if artists.length > 1 || rand
    respond_to do |format|
      format.js { render :partial => 'songs.js.erb' }
    end
  end
  
  private

  # accepts a string of grooveshark ids seperated by ',' symbols
  # returns a string of the same grooveshark ids in a different order
  def randomize(code)
    return code.split(',').sort_by{rand}.join(',')
  end
  
end
