class StartController < ApplicationController
  
  # TODO:: sanitize user input of artist name
  # TODO:: remove spaces from artist name
  # TODO:: handle case in which no results are found
  
  layout 'base.html.haml'
  
  def index
    @artist = Artist.new
  end
  
  def songs
    # determine whether lastfm data has already been stored for this artist
    # if data is less than a week old use the stored data
    # if data is more than a week old fetch new data from lastfm
    @artist = Artist.find_or_create_by_name(params[:artist][:name])
    if update?(@artist) || @artist.data == nil
      @data = JSON.parse(open("http://ws.audioscrobbler.com/2.0/?method=artist.getTopTracks&api_key=25c1d3e948b977d8893a92467d647a21&artist=" + @artist.name + "&format=json").read)
      @artist.data = JSON.generate(@data)
      @artist.fetch_count = @artist.fetch_count + 1
      @artist.refer_count = @artist.refer_count + 1
      @artist.last_fetch_at = Time.now
    else
      @data = JSON.parse(@artist.data)
      @artist.refer_count = @artist.refer_count + 1
    end
    @artist.save
    
    # use tinysong api to loop through list of tracks and get grooveshark ids
    # TODO:: validate the artist
    @data['toptracks']['track'].each do |track|
      @song = Song.find_or_create_by_name(track['name'].to_s, :artist => @artist)
      if @song.data == nil
        track_name = string_title(track['name'])
        artist_name = string_title(track['artist']['name'])
        @song_data = JSON.parse(open("http://tinysong.com/b/" + track_name + "+" + artist_name + "?format=json").read)
        @song.artist = @artist
        @song.data = JSON.generate(@song_data)
        @song.shark_id = @song_data['SongID']
      else
        @song_data = @song.data
      end
      @song.save
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
  def string_title(str)
    return str.to_s.gsub(/ /, "+")
  end
  
end
