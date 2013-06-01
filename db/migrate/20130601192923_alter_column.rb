class AlterColumn < ActiveRecord::Migration
  def up
    change_table :items do |t|
      t.change :image, :text, :limit => 5000
      t.change :source_url, :text, :limit => 5000
      t.change :title, :text, :limit => 5000
      t.change :subtitle, :text, :limit => 5000
      t.change :image, :text, :limit => 5000
      t.change :audio, :text, :limit => 5000
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
