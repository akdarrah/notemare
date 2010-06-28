class StartController < ApplicationController
  
  # TODO:: make update time dynamic
  # TODO:: add random / multiple artist support
  # TODO:: add similar artists feature
  # TODO:: indicate loading
  # TODO:: make sure songs belong to artist
  # TODO:: make format_for_lastFM only remove first 'the'
  # TODO:: throw an error when artist not found
  
  layout 'base.html.haml'
  
  def index
  end
  
  def songs
    # determine where to fetch the artist song data from (either lastfm or localhost)
    # and return a string of grooveshark ids to be injected into the player
    # first make a query to tinysong using the given artist name
    lookup = open("http://tinysong.com/b/" + format_for_URL(params[:artist][:name]) + "?format=json").read
    lookup_data = JSON.parse(lookup)

    # if lookup_data is an empty set you do not have a valid artist
    unless lookup_data == []
      @artist = Artist.find_or_create_by_name(format_for_URL(lookup_data['ArtistName']))
      @code = ""
      if update?(@artist) || @artist.data == nil
        @artist.data = open("http://ws.audioscrobbler.com/2.0/?method=artist.getTopTracks&api_key=25c1d3e948b977d8893a92467d647a21&artist=" + format_for_lastFM(@artist.name) + "&format=json").read
        @data = JSON.parse(@artist.data)
        @artist.fetch_count = @artist.fetch_count + 1
        @artist.refer_count = @artist.refer_count + 1
        @artist.last_fetch_at = Time.now
      
        ##################################### UPDATE SONGS
        # get the artists songs
        # use tinysong api to loop through list of tracks and get grooveshark ids
        @data['toptracks']['track'].each do |track|
          track_name = format_for_URL(format_song_for_tiny_song(track['name']))
          url = "http://tinysong.com/b/" + track_name + "+" + @artist.name + "?format=json"
          @song_data = JSON.parse(open(url).read)
          @code << @song_data['SongID'].to_s + ","
        end
        @artist.shark_code = @code

        ##################################### UPDATE SIMILAR ARTISTS
        # get similar artists and create similar artist objects
        @artist.similar_data = open("http://ws.audioscrobbler.com/2.0/?method=artist.getsimilar&artist=" + @artist.name + "&api_key=25c1d3e948b977d8893a92467d647a21&format=json").read
        @recommend_data = JSON.parse(@artist.similar_data)
      else
        # NO UPDATE REQUIRED
        @artist.refer_count = @artist.refer_count + 1
        @code = @artist.shark_code
        @recommend_data = JSON.parse(@artist.similar_data)
      end
      @artist.save
    
      respond_to do |format|
        format.html {render :action => "songs"}
        format.js { render :partial => 'songs.js.erb' }
      end
    end
  end
  
  private
  
  # compares Time.now to last update timestamp of artist object
  # if object has not been updated in a week, fetch new data from lastfm
  def update?(obj)
    return true if (Time.now - obj.last_fetch_at) > 1.week
    return false
  end
  
  # add + symbols in place of spaces to format a song or artist
  # name for making a query to tinysong
  def format_for_URL(str)
    return str.to_s.gsub(/ /, "+")
  end
  
  # strip all symbols from a song title when doing tinysong lookups
  def format_song_for_tiny_song(str)
    return str.to_s.gsub(/[[:punct:]]/, '')
  end
  
  # lowercases search term
  # removes unneeded words from the string
  def format_for_lastFM(str)
    parts = str.split('+')
    result = ""
    parts.each do |part|
      part = "" if part == "The" || part == "the"
      result << part
      result << "+" unless part == ""
    end
    result[result.length-1] = ''
    return result.downcase
  end
  
end
