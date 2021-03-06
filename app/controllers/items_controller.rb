class ItemsController < ApplicationController
  def index
    hashtag = params[:hashtag]

    require "statsmix"   
    StatsMix.api_key = "40ee2f0eddc89be16c42"


    # to add metadata, use the :meta symbol followed by a hash
    StatsMix.track("Searched Hashtag", 1, {:meta => {'name' => hashtag}})
    
    if StatsMix.error
      puts "Error: #{StatsMix.error}"
    end
    
    
   
    hash = Hashtag.find_or_create_by_name hashtag
            
    self.get_youtube_items_with_hash(hash)
    self.get_tweets_with_hash(hash)
    self.get_soundcloud_tracks_with_hash(hash)
    self.get_eyeem_items_with_hash(hash)
    
    
    render :json => hash.items.limit(30).sort_by { |i| i.timestamp }.reverse

  end
   
  def get_tweets_with_hash(hash)
    tweets = Twitter.search("#" << hash.name, {:count => 100, :result_type => 'mixed', :include_entities => true})

    filtered_tweets = []
    tweets[:statuses].each do |t|
      media_items = t[:media]
      media_items.each do |m|
        if m.instance_of?(Twitter::Media::Photo) 
          filtered_tweets << t
        end
      end
    end
    
    # [
    #   {
    #      "source_type": 'twitter'/'soundcloud'/'something else',
    #      "media": 'canonical url for picture' or 'http://api.soundcloud.com/tracks/13158665.json',
    #      "source_url": 'where to link, open page',
    #      "title": '(title when available)',
    #      "subtitle": '(description when available)',
    #      "timestamp": when item was created in standard rails time format
    #   },
    #   …
    # ]
    # http://rdoc.info/gems/twitter/Twitter/Tweet 
    filtered_tweets.each do |item|
      
      media_url = item[:media].first.media_url
      source_url = "https://twitter.com/" << item.from_user.to_s << "/status/" << item.id.to_s    
      # i = Item.find_or_initialize_by_media( media_url )
      i = Item.find_or_initialize_by_source_url( source_url )

      i.source_type = 'Twitter'
      i.image = item[:media].first.media_url
      i.source_url = source_url
      i.title = item.from_user
      i.subtitle = item.text
      i.timestamp = item[:created_at]
      unless i.hashtags.include?(hash)
         i.hashtags << hash
      end

      i.save
    end
    hash.save


  end
  
  def get_soundcloud_tracks_with_hash(hash)
    # TODO: the same as above!
    # create a client object with your app credentials
    client = Soundcloud.new(:client_id => '2826b6e0008b427559ece94781493083')

    # find all sounds of hashtag licensed under 'creative commons share alike'
    tracks = client.get('/tracks', :q => hash.name)

    # TODO: convert the hashes above to actual Item objects with a relationship to the hashtag object…
    tracks.each do |item|
      source_url = item.permalink_url

      i = Item.find_or_initialize_by_source_url( source_url )
    
      i.source_type = 'Soundcloud'
      if item.artwork_url.nil?
        i.image = 'assets/soundcloud.jpg'
      else 
        i.image = item.artwork_url 
      end
      i.audio = item.permalink_url
      i.title = item.username
      i.subtitle = item.description
      i.timestamp = item.created_at
      unless i.hashtags.include?(hash)
         i.hashtags << hash
      end

      i.save
    end
    hash.save
  end
  

  def get_eyeem_items_with_hash(hash) 
    albums = "https://www.eyeem.com/api/v2/albums?q=#{hash.name}&client_id=6ftAfogdmbXnQtYBA3jBD9NsJpvA3scD&limit=1"

    
    albums_response = HTTParty.get(albums)
    albums_json_parsed = ActiveSupport::JSON.decode(albums_response.body)

    #go through the responses to get albumId
    albums_json_parsed['albums']['items'].each do |item|
      album_id = item['id']
      photo_url = "https://www.eyeem.com/api/v2/albums/#{album_id}/photos?client_id=#{'6ftAfogdmbXnQtYBA3jBD9NsJpvA3scD'}&limit=10&detailed=1"
    photo_response = HTTParty.get(photo_url)
    photo_json_parsed = ActiveSupport::JSON.decode(photo_response.body)
    puts photo_json_parsed

    photo_json_parsed['photos']['items'].each do |item|
      source_url = item['webUrl']

      i = Item.find_or_initialize_by_source_url( source_url )
      
      i.source_type = 'Eyeem' 
      i.image = item['photoUrl']
      i.title = item['user']['nickname']
      i.subtitle = item['caption']
      i.timestamp = item['updated']
      unless i.hashtags.include?(hash)
        i.hashtags << hash
      end
    i.save

    end
    hash.save
    end
  end


  def get_youtube_items_with_hash(hash)
    
    videos = "https://gdata.youtube.com/feeds/api/videos?q=#{hash.name}&key=AI39si5dSwL7zXVMcZtgEIBzwjnpyNw4fpUBiTbMtWw5irVxxdAU25WaGoUKP4k7U5Bt0gXJCIS23Z8pE1BDtHFzxkOYRTh__Q&max-results=50&alt=json&v=2"

    videos_response = HTTParty.get(videos)
    videos_json_parsed = ActiveSupport::JSON.decode(videos_response.body)
  
    #go through the responses to get videos
    videos_json_parsed['feed']['entry'].each do |item|
      
      source_url_hash = item['link']
      source_url = source_url_hash[0]['href']
        
      i = Item.find_or_initialize_by_source_url( source_url )
      
      i.source_type = 'YouTube'

      image_hash = item['media$group']['media$thumbnail']
      i.image = image_hash[3]['url']
      i.video = item['content']['src']

      #i.title = trying to parse the json for the username is doing my head in
      #can't seem to get it and think it's because the final key
      #has a $ character in it (['author']['name']['$t'])

      i.subtitle = item['title']['$t']
      i.timestamp = item['updated']['$t']
      unless i.hashtags.include?(hash)
        i.hashtags << hash
      end
      puts i
      i.save
    end
  end


end

