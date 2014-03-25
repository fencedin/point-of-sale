require 'spec_helper'

describe Product do
  it { should have_many(:cashiers).through :transactions}
  it { should have_many :inventories }

end
