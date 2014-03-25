class Cashier < ActiveRecord::Base
  has_many :transactions
  has_many :products, through: :transactions
end
