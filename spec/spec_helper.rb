require 'rspec'
require 'active_record'
require 'shoulda-matchers'

require 'product'
require 'cashier'
require 'transaction'
require 'inventory'

ActiveRecord::Base.establish_connection(YAML::load(File.open('./db/config.yml'))["test"])

RSpec.configure do |config|
  config.after(:each) do
    Product.all.each { |product| product.destroy }
  end
end
