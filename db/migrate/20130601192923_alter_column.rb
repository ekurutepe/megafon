class AlterColumn < ActiveRecord::Migration

  def change
    change_table :items do |t|
      t.change :image, :text, 
      t.change :source_url, :text
      t.change :title, :text
      t.change :subtitle, :text
      t.change :image, :text
      t.change :audio, :text
    end
  end
  
  # def up
  #   change_table :items do |t|
  #     change_column :image, :text, 
  #     change_column :source_url, :text
  #     change_column :title, :text
  #     change_column :subtitle, :text
  #     change_column :image, :text
  #     change_column :audio, :text
  #   end
  # end

  # def down
  #   change_table :items do |t|
  #     change_column :image, :string
  #     change_column :source_url, :string
  #     change_column :title, :string
  #     change_column :subtitle, :string
  #     change_column :image, :string
  #     change_column :audio, :string
  #   end
  # end
end
