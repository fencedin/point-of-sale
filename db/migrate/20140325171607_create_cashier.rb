class CreateCashier < ActiveRecord::Migration
  def change
    create_table :cashiers do |t|
      t.column :name, :string
      t.column :password, :string

      t.timestamps
    end
  end
end
