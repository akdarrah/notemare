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
    
    # use tinysong api to loop through list of tracks and get grooveshark
    # ids for all songs.
    # @data = JSON.parse(open("http://ws.audioscrobbler.com/2.0/?method=artist.getTopTracks&api_key=25c1d3e948b977d8893a92467d647a21&artist=" + @artist.name + "&format=json").read)
    
    # if artist name is current artist get the next one
    
  end
  
  private
  
  # compares Time.now to last update timestamp of artist object
  # if object has not been updated in a week, fetch new data from lastfm
  def update?(artist)
    return true if (Time.now - artist.last_fetch_at) > 1.week
    return false
  end
  
end
