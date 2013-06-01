class CreateItemsHashtags < ActiveRecord::Migration
  def change
    create_table :hashtags_items, :id => false do |t|
      t.integer :hashtag_id
      t.integer :item_id
    end
  end
end
