class AddVideoToItems < ActiveRecord::Migration
  def change
    add_column :items, :video, :text
  end
end
