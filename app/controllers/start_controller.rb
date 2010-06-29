class StartController < ApplicationController
  
  # TODO:: make update time dynamic
  # TODO:: add similar artists feature
  # TODO:: indicate loading
  # TODO:: make sure songs belong to artist
  # TODO:: throw an error when artist not found
  
  layout 'base.html.haml'
  
  def index
  end
  
  def songs
    # get all artists user has entered
    artists = slice_string(params[:artist][:name])
    
    # if only one artist was entered, use the default algorithm
    if artists.length == 1
      @code = ""
      # determine where to fetch the artist song data from (either lastfm or localhost)
      # and return a string of grooveshark ids to be injected into the player
      # first make a query to tinysong using the given artist name
      lookup_data = JSON.parse(open("http://tinysong.com/b/" + format_for_URL(artists[0]) + "?format=json").read)

      # if lookup_data is an empty set you do not have a valid artist
      unless lookup_data == []
        # UPDATE REQUIRED
        @artist = Artist.find_or_create_by_name(format_for_URL(lookup_data['ArtistName']))
        if update?(@artist) || @artist.data == nil
          @artist.data = open("http://ws.audioscrobbler.com/2.0/?method=artist.getTopTracks&api_key=25c1d3e948b977d8893a92467d647a21&artist=" + format_for_lastFM(@artist.name) + "&format=json").read
          @data = JSON.parse(@artist.data)
          @artist.fetch_count = @artist.fetch_count + 1
          @artist.refer_count = @artist.refer_count + 1
          @artist.last_fetch_at = Time.now

          ##################################### UPDATE SONGS
          @data['toptracks']['track'].each do |track|
            track_name = format_for_URL(format_song_for_tiny_song(track['name']))
            @song_data = JSON.parse(open("http://tinysong.com/b/" + track_name + "+" + @artist.name + "?format=json").read)
            @code << @song_data['SongID'].to_s + ","
          end
          @artist.shark_code = @code

          ##################################### UPDATE SIMILAR ARTISTS
          @artist.similar_data = open("http://ws.audioscrobbler.com/2.0/?method=artist.getsimilar&artist=" + @artist.name + "&api_key=25c1d3e948b977d8893a92467d647a21&format=json").read
          @recommend_data = JSON.parse(@artist.similar_data)
        else
          # NO UPDATE REQUIRED
          @artist.refer_count = @artist.refer_count + 1
          @code = @artist.shark_code
          @recommend_data = JSON.parse(@artist.similar_data)
        end
        @artist.save
        
        @code = scramble(@code)
        respond_to do |format|
          format.html {render :action => "songs"}
          format.js { render :partial => 'songs.js.erb' }
        end
      end
    else
      # More than 1 artist was entered
      # loop through each artist given and compile a string of all shark codes
      @code = ""
      artists.each do |instance|
        # determine where to fetch the artist song data from (either lastfm or localhost)
        # and return a string of grooveshark ids to be injected into the player
        # first make a query to tinysong using the given artist name
        lookup_data = JSON.parse(open("http://tinysong.com/b/" + format_for_URL(instance) + "?format=json").read)

        # if lookup_data is an empty set you do not have a valid artist
        unless lookup_data == []
          # UPDATE REQUIRED
          @artist = Artist.find_or_create_by_name(format_for_URL(lookup_data['ArtistName']))
          if update?(@artist) || @artist.data == nil
            @artist.data = open("http://ws.audioscrobbler.com/2.0/?method=artist.getTopTracks&api_key=25c1d3e948b977d8893a92467d647a21&artist=" + format_for_lastFM(@artist.name) + "&format=json").read
            @data = JSON.parse(@artist.data)
            @artist.fetch_count = @artist.fetch_count + 1
            @artist.refer_count = @artist.refer_count + 1
            @artist.last_fetch_at = Time.now

            ##################################### UPDATE SONGS
            instance_code = ""
            @data['toptracks']['track'].each do |track|
              track_name = format_for_URL(format_song_for_tiny_song(track['name']))
              @song_data = JSON.parse(open("http://tinysong.com/b/" + track_name + "+" + @artist.name + "?format=json").read)
              instance_code << @song_data['SongID'].to_s + ","
            end
            @artist.shark_code = instance_code
            @code << @artist.shark_code

            ##################################### UPDATE SIMILAR ARTISTS
            @artist.similar_data = open("http://ws.audioscrobbler.com/2.0/?method=artist.getsimilar&artist=" + @artist.name + "&api_key=25c1d3e948b977d8893a92467d647a21&format=json").read
            @recommend_data = JSON.parse(@artist.similar_data)
          else
            # NO UPDATE REQUIRED
            @artist.refer_count = @artist.refer_count + 1
            @code << @artist.shark_code
            @recommend_data = JSON.parse(@artist.similar_data)
          end
          @artist.save
        end
      end
      # respond to request after all artists have been iterated
      @code = scramble(@code)
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
  
  # slices a string into an array divided at ',' symbols
  def slice_string(str)
    return str.split(',')
  end
  
  # accepts a string of grooveshark ids seperated by ',' symbols
  # returns a string of the same grooveshark ids in a different order
  def scramble(str)
    return str.split(',').sort_by{rand}.join(',')
  end
  
  # lowercases search term
  # removes unneeded words from the string
  def format_for_lastFM(str)
    part = str.split('+')
    part[0] = "" if part[0].downcase == "the"
    return part.join('+').downcase
  end
  
end
