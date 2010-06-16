class StartController < ApplicationController
  
  layout 'base.html.haml'
  
  def index
    # puts JSON.parse(open("http://ws.audioscrobbler.com/2.0/?method=artist.getTopTracks&api_key=25c1d3e948b977d8893a92467d647a21&artist=thedecemberists&format=json").read)
  end
  
end
