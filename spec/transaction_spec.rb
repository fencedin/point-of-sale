require 'spec_helper'

describe Transaction do
  it { should belong_to :product }
  it { should belong_to :cashier }
end
