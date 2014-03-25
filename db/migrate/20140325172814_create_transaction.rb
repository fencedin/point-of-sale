class CreateTransaction < ActiveRecord::Migration
  def change
    create_table :transactions do |t|
      t.belongs_to :product
      t.belongs_to :cashier
      t.timestamps
    end
  end
end
