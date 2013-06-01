class AlterColumn < ActiveRecord::Migration
  def up
    change_table :items do |t|
      t.change :image, :text
      t.change :source_url, :text
      t.change :title, :text
      t.change :subtitle, :text
      t.change :image, :text
      t.change :audio, :text
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
