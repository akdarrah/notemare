class ArtistController < ApplicationController
  
  # FEATURE:: make update time dynamic
  # FEATURE:: add similar artists feature ?
  # FEATURE:: make sure songs belong to artist
  # FEATURE:: add 'Mix' model for saving playlists
  # FEATURE:: add embed code into site and share links
  # FEATURE:: inline application helpers
  # FEATURE:: add admin section
    # Audit artist form (sphinx or DB LIKE)
    # Delayed Jobs interface
  # FEATURE:: throw an error when artist not found
  # CHORE:: automate database backups
  # BUG:: n ruby processes are created during import
  # CHORE:: allow user to manipulate artist preview
  
  # gunzip < [backupfile.sql.gz] | mysql -u [uname] -p[pass] [dbname]
  
  layout 'base.html.haml'
  
  def index
  end
  
  def songs
    # get all artists user has entered
    artists = params[:artist][:name].split(',')
    @code = ""
    @data = {}
    
    # determine whether to randomize the results or not
    # if user inserted a ! into input, remove it
    rand = true if artists[0][-1,1] == '!'
    artists[0] = artists[0].split("!")[0] if rand
    
    # loop through each artist given and compile a string of all shark codes
    artists.each do |instance|
      # make a query to tinysong using the given artist name
      lookup_data = JSON.parse(open("#{Artist::TINYSONG_BASE_URL}#{instance.to_url}?format=json").read)
      # if lookup_data is an empty set you do not have a valid artist
      unless lookup_data == []
        @artist = Artist.find_or_create_by_name(lookup_data['ArtistName'].to_url)
        @artist.enqueue(@artist.shark_code.present? ? false : true)
        @artist.fetch if @artist.data.nil? || @artist.similar_data.nil? || @artist.shark_code.nil?
        artist_data = @artist.get_data
        @code << artist_data[:code]
        artist = JSON.parse(artist_data[:data])
        @data[artist['artist']['name']] = {:name => artist['artist']['name'], :amazon_link_name => artist['artist']['name'].to_url, :image => artist['artist']['image'][1]['#text'], :lastFM => artist['artist']['url']}
      end
    end
    # respond to request after all artists have been iterated
    @code = randomize(@code) if artists.length > 1 || rand
    respond_to do |format|
      format.js { render :partial => 'songs.js.erb' }
    end
  end
  
  private

  # accepts a string of grooveshark ids seperated by ',' symbols
  # returns a string of the same grooveshark ids in a different order
  def randomize(code)
    return code.split(',').sort_by{rand}.join(',')
  end
  
end
