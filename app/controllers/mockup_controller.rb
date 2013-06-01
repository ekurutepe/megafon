class MockupController < ApplicationController
  def index
    render :json => '[
      {
       "source_type": "twitter",
       "media": "http://api.soundcloud.com/tracks/13158665.json",
       "source_url": "where to link, open page",
       "title": "mockup title",
       "subtitle": "mockup SUBBBtitle",
       "timestamp": "asd"
      }
    ]'
  end

end
