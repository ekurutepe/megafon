class Item < ActiveRecord::Base
  attr_accessible :media, :source_type, :source_url, :subtitle, :timestamp, :title
end
