class ItemsController < ApplicationController
  def index
    hashtag = params[:hashtag]

    StatsMix.api_key = "40ee2f0eddc89be16c42"
  
    # to add metadata, use the :meta symbol followed by a hash
    StatsMix.track("Searched Hashtag", 1, {:meta => {'name' => hashtag}})
    
    if StatsMix.error
      puts "Error: #{StatsMix.error}"
    end
    
    
    hash = Hashtag.find_or_create_by_name hashtag
            
    # self.get_tweets_with_hash(hash)
    # self.get_soundcloud_tracks_with_hash(hash)
    # self.get_eyeem_items_with_hash(hash)
    self.get_youtube_items_with_hash(hash)
    
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

      i.source_type = 'twitter'
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
    
      i.source_type = 'soundcloud'
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
      
      i.source_type = 'eyeem' 
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
    
    videos = "https://gdata.youtube.com/feeds/api/videos?q=#{hash.name}&key=AI39si5dSwL7zXVMcZtgEIBzwjnpyNw4fpUBiTbMtWw5irVxxdAU25WaGoUKP4k7U5Bt0gXJCIS23Z8pE1BDtHFzxkOYRTh__Q&max-results=10&alt=json&v=2"
    puts videos

    videos_response = HTTParty.get(videos)
    videos_json_parsed = ActiveSupport::JSON.decode(videos_response.body)

    puts videos_json_parsed
    
    #go through the responses to get videos
    videos_json_parsed['feed']['entry'].each do |item|
      source_url = item['link']['href']


        
      i = Item.find_or_initialize_by_source_url( source_url )
      
      i.source_type = 'YouTube' 
      i.image = item['media$group']['media$thumbnail']['url']
      i.title = item['author']['name']
      i.subtitle = item['title']
      i.timestamp = item['updated']
      unless i.hashtags.include?(hash)
        i.hashtags << hash
      end
      puts i
      i.save
    end
  end


end

#https://gdata.youtube.com/feeds/api/videos/-/category_or_tag
