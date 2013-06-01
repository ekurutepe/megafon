class CreateItems < ActiveRecord::Migration
  def change
    create_table :items do |t|
      t.string :source_type
      t.string :media
      t.string :source_url
      t.string :title
      t.string :subtitle
      t.timestamp :timestamp

      t.timestamps
    end
  end
end
