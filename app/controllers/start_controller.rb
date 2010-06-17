class StartController < ApplicationController
  
  # TODO:: sanitize user input of artist name
  # TODO:: remove spaces from artist name
  # TODO:: handle case in which no results are found
  
  layout 'base.html.haml'
  
  def index
    @artist = Artist.new
  end
  
  def songs
    @artist = Artist.find_or_create_by_name(params[:artist][:name])
    @data = JSON.parse(open("http://ws.audioscrobbler.com/2.0/?method=artist.getTopTracks&api_key=25c1d3e948b977d8893a92467d647a21&artist=" + params[:artist][:name] + "&format=json").read)
    
    # determine whether lastfm data has already been stored for this artist
    # if data is less than a week old use the stored data
    # if data is more than a week old fetch new data from lastfm
        
    @artist.data = JSON.generate(@data)
    @artist.save
  end
  
  private
  
  # compares Time.now to last update timestamp of artist object
  # if object has not been updated in a week, fetch new data from lastfm
  def update?(artist)
    return true if (Time.now - artist.updated_at) > 1.week
    return false
  end
  
end
