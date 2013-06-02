class ItemsController < ApplicationController
  def index
    hashtag = params[:hashtag]
    
    hash = Hashtag.find_or_create_by_name hashtag
            
    self.get_tweets_with_hash(hash)
    self.get_soundcloud_tracks_with_hash(hash)
    
    render :json => hash.items.limit(20)

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
        i.image = 'http://blog.soundcloud.com/wp-content/uploads/2011/06/soundcloud_logo.gif'
      else 
        i.image = item.artwork_url 
      end
      i.audio = item.permalink_url
      i.title = item.username
      i.subtitle = item.description
      unless i.hashtags.include?(hash)
         i.hashtags << hash
      end

      i.save
    end
    hash.save
  end
  
  
end

