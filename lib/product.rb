class Product < ActiveRecord::Base
  has_many :transactions
  has_many :cashiers, through: :transactions
  has_many :inventories
end
