class ArtistController < ApplicationController
  
  # POST DEPLOY
  # ##################################################
  # FEATURE:: make artist preview better
  # FEATURE:: make update time dynamic
  # CHORE:: automate database backups
    
  layout 'base.html.haml'
  
  def index
  end
  
  # if user enters site with a generated url
  # basically just need to determine if they are looking up a mix or an artist
  # then set all the needed data and render the page .. simple
  def lookup
    @code = @player_code = ""
    @data = {}
    @artist = Artist.find_by_name(params[:id])
    @mix = Mix.find_by_id(params[:id].to_i(36)) if @artist.nil?
    @search_bar = ""
    
    # set needed instance vars
    if @artist.present? || @mix.present?
      @page_url = "http://notemare.com/#{params[:id]}"
      if @artist.present?
        @code = @artist.shark_code
        @search_bar_text = @artist.name
        artist = JSON.parse(@artist.data)
        @data[artist['artist']['name']] = {:name => artist['artist']['name'], :amazon_link_name => artist['artist']['name'].to_url, :image => artist['artist']['image'][1]['#text'], :lastFM => artist['artist']['url']}
      else
        @code = @mix.shark_code
        @search_bar_text = @mix.artists.map(&:name).join(",")
        @mix.artists.each do |artist|
          artist = JSON.parse(artist.data)
          @data[artist['artist']['name']] = {:name => artist['artist']['name'], :amazon_link_name => artist['artist']['name'].to_url, :image => artist['artist']['image'][1]['#text'], :lastFM => artist['artist']['url']}
        end
      end
      @search_bar_text = @search_bar_text.gsub("+", " ").gsub(",", ", ")
      @player_code = "<object width='400' height='400'><param value='http://listen.grooveshark.com/widget.swf' name='movie'><param value='window' name='wmode'><param value='always' name='allowScriptAccess'><param value='hostname=cowbell.grooveshark.com&amp;songIDs=#{@code}&amp;style=metal&amp;bbg=000000&amp;bt=FFFFFF&amp;bfg=666666&amp;p=0' name='flashvars'><embed width='400' height='400' wmode='window' allowscriptaccess='always' flashvars='hostname=cowbell.grooveshark.com&amp;songIDs=#{@code}&amp;style=metal&amp;bbg=000000&amp;bt=FFFFFF&amp;bfg=666666&amp;p=0' type='application/x-shockwave-flash' src='http://listen.grooveshark.com/widget.swf'></object>"
    else
      redirect_to root_url
    end
  end
  
  def songs

    if params.present? && params[:artist].nil?
      redirect_to root_url
      return
    end
    
    # get all artists user has entered
    artists = params[:artist][:name].split(',')
    @code = @player_code = ""
    @data = {}
    
    # contains all artist objects in current request
    current = []
    
    if artists.length == 1
      # determine whether to randomize the results or not
      # if user inserted a ! into input, remove it
      rand = true if artists[0].present? && artists[0][-1,1] == '!'
      artists[0] = artists[0].split("!")[0] if rand
      
      # determine whether to include similar artists
      # if user inserted a ? into input, remove it
      sim = true if artists[0].present? && artists[0][-1,1] == '?'
      artists[0] = artists[0].split("?")[0] if sim
      
      # if sim is true, we need to append similar artists to artists array before looping
      # this requires an additional tinysong and Artist lookup to do
      # THIS SUCKS -> REFACTOR IF POSSIBLE
      if sim == true && artists[0].present?
        base_artist = Artist.find_by_name(artists[0].to_url)
        lookup_data = JSON.parse(open("#{Artist::TINYSONG_BASE_URL}artist:#{artists[0].to_url}?format=json").read) if base_artist.nil?
        unless lookup_data == []
          base_artist ||= Artist.find_or_create_by_name(lookup_data['ArtistName'].to_url)
          base_artist.enqueue(base_artist.shark_code.present? ? false : true)
          base_artist.fetch if base_artist.data.nil? || base_artist.similar_data.nil? || base_artist.shark_code.nil?
          JSON.parse(base_artist.similar_data)['similarartists']['artist'][0..2].each do |sa|
            artists << sa['name']
          end
        end
      end
    end
            
    # loop through each artist given and compile a string of all shark codes
    artists.each do |instance|
      next if instance.nil?
      @artist = Artist.find_by_name(instance.to_url)
      lookup_data = JSON.parse(open("#{Artist::TINYSONG_BASE_URL}artist:#{instance.to_url}?format=json").read) if @artist.nil?
      # if lookup_data is an empty set you do not have a valid artist
      unless lookup_data == []
        @artist ||= Artist.find_or_create_by_name(lookup_data['ArtistName'].to_url)
        @artist.enqueue(@artist.shark_code.present? ? false : true)
        @artist.fetch if @artist.data.nil? || @artist.similar_data.nil? || @artist.shark_code.nil?
        artist_data = @artist.get_data
        @code << artist_data[:code]
        current << @artist
        artist = JSON.parse(artist_data[:data])
        @data[artist['artist']['name']] = {:name => artist['artist']['name'], :amazon_link_name => artist['artist']['name'].to_url, :image => artist['artist']['image'][1]['#text'], :lastFM => artist['artist']['url']}
      end
    end
    
    # render an error message if there is no data in the code
    # if no data in code, grooveshark player will be rendered with no songs just fine
    # however, this will interup the current player. rendering this partial will not.
    if @code.blank?
      respond_to do |format|
        format.js { render :partial => 'error.js.erb' }
      end
      return
    end
    
    # respond to request after all artists have been iterated
    @code = randomize(@code) if artists.length > 1 || rand
    
    # set @page_url to a returnable url address
    if artists.length == 1
      @page_url = "http://notemare.com/#{current[0].name}"
    else
      @mix = Mix.create(:shark_code => @code)
      current.each{|inc| @mix.artists << inc}
      @page_url = "http://notemare.com/#{@mix.id.to_s(36)}"
    end
    
    @player_code = "<object width='400' height='400'><param value='http://listen.grooveshark.com/widget.swf' name='movie'><param value='window' name='wmode'><param value='always' name='allowScriptAccess'><param value='hostname=cowbell.grooveshark.com&amp;songIDs=#{@code}&amp;style=metal&amp;bbg=000000&amp;bt=FFFFFF&amp;bfg=666666&amp;p=0' name='flashvars'><embed width='400' height='400' wmode='window' allowscriptaccess='always' flashvars='hostname=cowbell.grooveshark.com&amp;songIDs=#{@code}&amp;style=metal&amp;bbg=000000&amp;bt=FFFFFF&amp;bfg=666666&amp;p=0' type='application/x-shockwave-flash' src='http://listen.grooveshark.com/widget.swf'></object>"
    
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
