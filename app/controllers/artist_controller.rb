class ArtistController < ApplicationController
  
  # FEATURE:: make update time dynamic
  # FEATURE:: add similar artists feature
  # FEATURE:: make sure songs belong to artist
  # FEATURE:: throw an error when artist not found
  # FEATURE:: add 'Mix' model for saving playlists
  # FEATURE:: add embed code into site and share links
  # FEATURE:: inline application helpers
  # FEATURE:: add admin section
    # Audit artist form
    # Delayed Jobs interface
  # CHORE:: queue jobs at set time interval instead of now
  # CHORE:: on timeout, schedule update in 1 day
  # CHORE:: make all urls overridable
  # CHORE:: make artist_data support multiple artists
  # CHORE:: make get similar artists a background job to execute later if not requested

  layout 'base.html.haml'
  
  def index
  end
  
  def songs
    # get all artists user has entered
    artists = params[:artist][:name].split(',')
    @code = ""
    
    # determine whether to randomize the results or not
    # if user inserted a ! into input, remove it
    rand = true if artists[0][-1,1] == '!'
    artists[0] = artists[0].split("!")[0] if rand
    
    # loop through each artist given and compile a string of all shark codes
    artists.each do |instance|
      # make a query to tinysong using the given artist name
      lookup_data = JSON.parse(open("http://tinysong.com/b/" + instance.to_url + "?format=json").read)
      # if lookup_data is an empty set you do not have a valid artist
      unless lookup_data == []
        @artist = Artist.find_or_create_by_name(lookup_data['ArtistName'].to_url)
        @artist.expired?
        if @artist.data.nil? || @artist.similar_data.nil? || @artist.shark_code.nil?
          @artist.fetch
        end
        artist_data = @artist.get_data
        @code << artist_data[:code]
        artist = JSON.parse(artist_data[:data])
        @data = {:name => artist['artist']['name'], :amazon_link_name => artist['artist']['name'].to_url, :image => artist['artist']['image'][1]['#text'], :lastFM => artist['artist']['url']}
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
