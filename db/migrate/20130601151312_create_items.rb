class CreateItems < ActiveRecord::Migration
  def change
    create_table :items do |t|
      t.string :source_type
      t.text :media
      t.text :source_url
      t.text :title
      t.text :subtitle
      t.timestamp :timestamp

      t.timestamps
    end
  end
end
