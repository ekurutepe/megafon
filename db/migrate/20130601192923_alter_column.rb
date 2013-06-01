class AlterColumn < ActiveRecord::Migration

  def up
    change_table :items do |t|
      change_column :image, :string, :limit => 5000
      change_column :source_url, :string, :limit => 5000
      change_column :title, :string, :limit => 5000
      change_column :subtitle, :string, :limit => 5000
      change_column :image, :string, :limit => 5000
      change_column :audio, :string, :limit => 5000
    end
  end

  def down
    change_table :items do |t|
      change_column :image, :string
      change_column :source_url, :string
      change_column :title, :string
      change_column :subtitle, :string
      change_column :image, :string
      change_column :audio, :string
    end
  end
end
