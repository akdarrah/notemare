class StartController < ApplicationController
  
  # FEATURE:: make update time dynamic
  # FEATURE:: add similar artists feature
  # FEATURE:: make sure songs belong to artist
  # FEATURE:: throw an error when artist not found
  # FEATURE:: add 'Mix' model for saving playlists
  # FEATURE:: add embed code into site and share links
  # FEATURE:: add amazon adds/link to lastfm profile
  
  # FEATURE:: site styles
  # FEATURE:: inline application helpers
  # FEATURE:: add admin section
    # Audit artist form
    # Delayed Jobs interface
  # CHORE:: make artist model store source_url so it can be overriden
  
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
      lookup_data = JSON.parse(open("http://tinysong.com/b/" + to_URL(instance) + "?format=json").read)
      # if lookup_data is an empty set you do not have a valid artist
      unless lookup_data == []
        @artist = Artist.find_or_create_by_name(to_URL(lookup_data['ArtistName']))
        @artist.expired?
        if @artist.data.nil? || @artist.similar_data.nil? || @artist.shark_code.nil?
          @artist.fetch
        end
        @code << @artist.get_data[:code]
      end
    end
    # respond to request after all artists have been iterated
    @code = randomize(@code) if artists.length > 1 || rand
    respond_to do |format|
      format.js { render :partial => 'songs.js.erb' }
    end
  end
  
  private

  # add + symbols in place of spaces to format a song or artist
  # name for making a query to tinysong
  def to_URL(str)
    return str.to_s.gsub(/ /, "+")
  end
  
  # accepts a string of grooveshark ids seperated by ',' symbols
  # returns a string of the same grooveshark ids in a different order
  def randomize(code)
    return code.split(',').sort_by{rand}.join(',')
  end
  
end
