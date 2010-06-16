class StartController < ApplicationController
  
  # TODO:: sanitize user input of artist name
  # TODO:: remove spaces from artist name
  # TODO:: handle case in which no results are found
  
  layout 'base.html.haml'
  
  def index
  end
  
  def search
    @search = JSON.parse(open("http://ws.audioscrobbler.com/2.0/?method=artist.search&artist=" + remove_spaces(params[:artist][:name]) + "&api_key=25c1d3e948b977d8893a92467d647a21&format=json").read)
  end
  
  def songs
    @data = JSON.parse(open("http://ws.audioscrobbler.com/2.0/?method=artist.getTopTracks&api_key=25c1d3e948b977d8893a92467d647a21&artist=" + remove_spaces(params[:artist][:name]) + "&format=json").read)
  end
  
  private
  
  def remove_spaces(string)
    return string.gsub(/ /, "")
  end
  
end
