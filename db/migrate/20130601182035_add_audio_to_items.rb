class AddAudioToItems < ActiveRecord::Migration
  def change
    add_column :items, :audio, :string
  end
end
