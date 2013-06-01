class ItemsController < ApplicationController
  def index
    tweets = Twitter.search(params[:hashtag], :count => 20, :result_type => 'popular', :filter => 'links', :include_entities => true)
    
    

    filtered_tweets = []
    tweets[:statuses].each do |t|
      media_items = t[:media]
      media_items.each do |m|
        if m.instance_of?(Twitter::Media::Photo) 
          filtered_tweets << t
        end
      end
    end
    render :json => filtered_tweets
  end
  
  
end

