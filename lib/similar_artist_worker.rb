# schedules jobs to update all artists similar to given id
require 'artist'
class SimilarArtistWorker < Struct.new(:artist_id)
  def perform
    @artist = Artist.find(artist_id)
    @artist.queue_similar_artists
  end
end