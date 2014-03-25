require 'spec_helper'


describe Cashier do
  it { should have_many(:products).through :transactions  }
end
