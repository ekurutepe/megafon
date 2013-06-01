class RenameMediaToImageInItem < ActiveRecord::Migration
  def up
    rename_column(:items, :media, :image)
  end

  def down
    rename_column(:items, :image, :media)
  end
end
