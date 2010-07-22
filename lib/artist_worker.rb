require 'artist'
class ArtistWorker < Struct.new(:artist_id)
  def perform
    @artist = Artist.find(artist_id)
    @artist.fetch
  end
end