class ItemsController < ApplicationController
  def index
    render :json => {:text => 'hello world'}
  end
end
