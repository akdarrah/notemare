class StartController < ApplicationController
  
  # TODO:: handle case in which no results are found
  # TODO:: strip symbols out of song titles
  # TODO:: make update time dynamic
  # TODO:: improve artist validation
  # TODO:: add random / multiple artist support
  # TODO:: add similar artists feature
  # TODO:: indicate loading
  
  layout 'base.html.haml'
  
  def index
  end
  
  def songs
    # determine where to fetch the artist song data from (either lastfm or localhost)
    # and return a string of grooveshark ids to be injected into the player
    @artist = Artist.find_or_create_by_name(string_title(params[:artist][:name]))
    @code = ""
    if update?(@artist) || @artist.data == nil
      @artist.data = open("http://ws.audioscrobbler.com/2.0/?method=artist.getTopTracks&api_key=25c1d3e948b977d8893a92467d647a21&artist=" + @artist.name + "&format=json").read
      @data = JSON.parse(@artist.data)
      @artist.fetch_count = @artist.fetch_count + 1
      @artist.refer_count = @artist.refer_count + 1
      @artist.last_fetch_at = Time.now
      
      ##################################### UPDATE SONGS
      # get the artists songs
      # use tinysong api to loop through list of tracks and get grooveshark ids
      ts_artist = tiny_song_artist(@data['toptracks']['track'][0])
      @data['toptracks']['track'].each do |track|
        track_name = string_title(track['name'])
        artist_name = string_title(track['artist']['name'])
        @song_data = JSON.parse(open("http://tinysong.com/b/" + track_name + "+" + artist_name + "?format=json&limit=3").read)
        @code << groove_id(@song_data, ts_artist)
      end
      @artist.shark_code = @code

      ##################################### UPDATE SIMILAR ARTISTS
      # get similar artists and create similar artist objects
      @artist.similar_data = open("http://ws.audioscrobbler.com/2.0/?method=artist.getsimilar&artist=" + @artist.name + "&api_key=25c1d3e948b977d8893a92467d647a21&format=json").read
      @recommend_data = JSON.parse(@artist.similar_data)
      
    else
      # NO UPDATE REQUIRED
      @data = JSON.parse(@artist.data)
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
  
  private
  
  # given json data from tinysong api for a given song and artist
  # return the grooveshark id for the appropriate song as long
  # as artistname is the expected artistname
  def groove_id(data, artist_name)
    return data['SongID'].to_s + "," if data['ArtistName'] == artist_name
    return ""
  end
  
  # use the most popular song and artist name to make a query to tinysong
  # get the result and use it to determine how tinysong refers to the artist name
  def tiny_song_artist(data)
    track = string_title(data['name'])
    artist = string_title(data['artist']['name'])
    s_data = JSON.parse(open("http://tinysong.com/b/" + track + "+" + artist + "?format=json").read)
    return s_data['ArtistName']
  end
  
  # compares Time.now to last update timestamp of artist object
  # if object has not been updated in a week, fetch new data from lastfm
  def update?(obj)
    return true if (Time.now - obj.last_fetch_at) > 1.week
    return false
  end
  
  # add + symbols in place of spaces to format a song or artist
  # name for making a query to tinysong
  def string_title(str)
    return str.to_s.gsub(/ /, "+")
  end
  
end
