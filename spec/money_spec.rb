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
  
  describe 'when accessing a document from the datastore with multiple Money datatypes' do
    before(:each) do
      DummyPrices.create(description: "Test", price3: '1', price1: '1.23', price2: '2.33')
    end
    
    it 'should have correct Money value for field 1' do
      dummy = DummyPrices.first
      dummy.price1.should eq Money.parse('1.23')
    end
    it 'should have correct Money value for field 2' do
      dummy = DummyPrices.first
      dummy.price2.should eq Money.parse('2.33')
    end
    it 'should have correct Money value for field 3' do
      dummy = DummyPrices.first
      dummy.price3.should eq Money.parse('1')
    end
  end  
end