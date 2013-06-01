class Item < ActiveRecord::Base
  attr_accessible :media, :source_type, :source_url, :subtitle, :timestamp, :title
  has_and_belongs_to_many :hashtags
end
