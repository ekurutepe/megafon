class AlterColumn < ActiveRecord::Migration

  def change
    change_table :items do |t|
      t.change :image, :string, :limit => 5000
      t.change :source_url, :string, :limit => 5000
      t.change :title, :string, :limit => 5000
      t.change :subtitle, :string, :limit => 5000
      t.change :image, :string, :limit => 5000
      t.change :audio, :string, :limit => 5000
    end
  end
end
