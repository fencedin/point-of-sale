class CreateInventory < ActiveRecord::Migration
  def change
    create_table :inventories do |t|
      t.belongs_to :product
      t.column :in_stock, :boolean
    end
  end
end
