require 'spec_helper'

describe Mongoid::MoneyField do
  
  describe 'when persisting a document with a Money datatype' do
  
    it 'should be persisted normally when set as dollars' do
      dummy = DummyMoney.new
      dummy.price = '$10'
      dummy.save.should eq true
    end
    
    it 'should be persisted normally when set as cents' do
      dummy = DummyMoney.new
      dummy.price = '$9.99'
      dummy.save.should eq true
    end
  end
  
  describe 'when accessing a document from the datastore with a Money datatype' do
    before(:each) do
      DummyMoney.create(:description => "Test", :price => '9.99')
    end
    
    it 'should have a Money value that matches the money value that was initially persisted' do
      dummy = DummyMoney.first
      dummy.price.should eq Money.parse('9.99')
    end
  end
  
  describe 'when accessing a document from the datastore with a Money datatype and empty value' do
    before(:each) do
      DummyMoney.create(:description => "Test")
    end
    
    it 'should have a Money value of 0' do
      dummy = DummyMoney.first
      dummy.price.should eq Money.parse('0')
    end
  end

  describe 'when accessing a document from the datastore with a Money datatype and blank value' do
    before(:each) do
      DummyMoney.create(description: "Test", price: '')
    end
    
    it 'should have a Money value of 0' do
      dummy = DummyMoney.first
      dummy.price.should eq Money.parse('0')
    end
  end  
end