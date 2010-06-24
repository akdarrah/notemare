class StartController < ApplicationController
  
  # TODO:: sanitize user input of artist name
  # TODO:: handle case in which no results are found
  # TODO:: strip symbols out of song titles
  # TODO:: make update time dynamic
  # TODO:: improve artist validation
  # TODO:: add random / multiple artist support
  # TODO:: make everything ajax
  # TODO:: add similar artists to player page
  # TODO:: search for artist first to make sure valid artist
  
  layout 'base.html.haml'
  
  def index
    @artist = Artist.new
  end
  
  def songs
    # determine whether lastfm data has already been stored for this artist
    # if data is less than a week old use the stored data
    # if data is more than a week old fetch new data from lastfm
    @artist = Artist.find_or_create_by_name(string_title(params[:artist][:name]))
    @code = ""
    if update?(@artist) || @artist.data == nil
      @data = JSON.parse(open("http://ws.audioscrobbler.com/2.0/?method=artist.getTopTracks&api_key=25c1d3e948b977d8893a92467d647a21&artist=" + @artist.name + "&format=json").read)
      @artist.data = JSON.generate(@data)
      @artist.fetch_count = @artist.fetch_count + 1
      @artist.refer_count = @artist.refer_count + 1
      @artist.last_fetch_at = Time.now
      # use tinysong api to loop through list of tracks and get grooveshark ids
      ts_artist = tiny_song_artist(@data['toptracks']['track'][0])
      @data['toptracks']['track'].each do |track|
        track_name = string_title(track['name'])
        artist_name = string_title(track['artist']['name'])
        @song_data = JSON.parse(open("http://tinysong.com/b/" + track_name + "+" + artist_name + "?format=json&limit=3").read)
        @code << groove_id(@song_data, ts_artist).to_s + ","
      end
      @artist.shark_code = @code
    else
      @data = JSON.parse(@artist.data)
      @artist.refer_count = @artist.refer_count + 1
      @code = @artist.shark_code
    end
    @artist.save
  end
  
  private
  
  # given json data from tinysong api for a given song and artist
  # return the grooveshark id for the appropriate song as long
  # as artistname is the expected artistname
  def groove_id(data, artist_name)
    return data['SongID'] if data['ArtistName'] == artist_name
  end
  
  # use the most popular song and artist name to make a query to tinysong
  # get the result and use it to determine how tinysong refers to the artist name
  def tiny_song_artist(data)
    track = string_title(data['name'])
    artist = string_title(data['artist']['name'])
    s_data = JSON.parse(open("http://tinysong.com/b/" + track + "+" + artist + "?format=json&limit=3").read)
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
