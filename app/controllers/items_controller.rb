class ItemsController < ApplicationController
  def index
    tweets = Twitter.search(params[:hashtag], :count => 2000, :result_type => 'all', :filter => 'links', :include_entities => true)
    

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
    render :json => formatted_results

    #
  end
  
  
end

