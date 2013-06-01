class ItemsController < ApplicationController
  def index
    #TODO: call get_tweets
    #TODO: call get_soundcloud
    #TODO: fetch item with relationship hashtag and return
    hashtag = params[:hashtag]
    self.get_soundcloud_tracks_with_hashtag(hashtag)
  end
  
  
  def get_tweets_with_hashtag(hashtag)
    tweets = Twitter.search("#" << params[:hashtag], :count => 2000, :result_type => 'all', :filter => 'links', :include_entities => true)
    

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

    formatted_results = filtered_tweets.map { |item| {:source_type => 'twitter', :media => item[:media].first.media_url, :source_url => "https://twitter.com/" << item.from_user.to_s << "/status/" << item.id.to_s, :title => item.from_user,:subtitle => item.text}}
    # TODO: convert the hashes above to actual Item objects with a relationship to the hashtag object…
    render :json => formatted_results
  end
  















  
  def get_soundcloud_tracks_with_hashtag(hashtag)
    # TODO: the same as above!
    # create a client object with your app credentials
    client = Soundcloud.new(:client_id => '2826b6e0008b427559ece94781493083')

    # find all sounds of hashtag licensed under 'creative commons share alike'
    tracks = client.get('/tracks', :q => hashtag, :licence => 'cc-by-sa')


    formatted_results2 = tracks.map { |item| {:source_type => 'soundcloud', :media => item.permalink, :source_url => item.permalink_url, :title => item.username,:subtitle => item.description}}
    # TODO: convert the hashes above to actual Item objects with a relationship to the hashtag object…
    render :json => formatted_results2

  end
  
  
end

