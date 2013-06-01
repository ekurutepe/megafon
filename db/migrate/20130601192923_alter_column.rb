class AlterColumn < ActiveRecord::Migration
  def up
    change_table :items do |t|
      change_column :image, :text, :limit => nil
      change_column :source_url, :text, :limit => nil
      change_column :title, :text, :limit => nil
      change_column :subtitle, :text, :limit => nil
      change_column :image, :text, :limit => nil
      change_column :audio, :text, :limit => nil
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
