class AlterColumn < ActiveRecord::Migration

  def up
    change_table :items do |t|
      t.change :image, :text, :limit => nil
      t.change :source_url, :text, :limit => nil
      t.change :title, :text, :limit => nil
      t.change :subtitle, :text, :limit => nil
      t.change :image, :text, :limit => nil
      t.change :audio, :text, :limit => nil
    end
  end

  def down
    change_table :items do |t|
      t.change :image, :string
      t.change :source_url, :string
      t.change :title, :string
      t.change :subtitle, :string
      t.change :image, :string
      t.change :audio, :string
    end
  end
end
