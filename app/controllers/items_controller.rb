class ItemsController < ApplicationController
  def index
    hashtag = params[:hashtag]
    
    hash = Hashtag.find_or_create_by_name hashtag
            
    self.get_tweets_with_hash hash
    
    #TODO: call get_soundcloud
    

    
    render :json => hash.items.all
  end
  
  
  def get_tweets_with_hash(hash)
    tweets = Twitter.search("#" << hash.name, :count => 2000, :result_type => 'all', :filter => 'links', :include_entities => true)

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
      source_url = "https://twitter.com/" << item.from_user.to_s << "/status/" << item.id.to_s
      i = Item.find_or_initialize_by_source_url( source_url )
    
      i.source_type = 'twitter'
      i.media = item[:media].first.media_url
      i.title = item.from_user
      i.subtitle = item.text
      i.hashtags << hash
      i.save
    end
    hash.save
    
  end
  
  def get_soundcloud_tracks_with_hashtag(hashtag)
    # TODO: the same as above!
  end
  
  
end

