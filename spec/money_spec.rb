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
    
    it 'should be persisted normally when set as Money' do
      dummy = DummyMoney.new
      dummy.price = Money.parse(1.23)
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
  
  describe 'when accessing a document from the datastore with a Money datatype set as money' do
    before(:each) do
      dm = DummyMoney.create(:description => "Test")
      dm.price = Money.parse('1.23')
      dm.save!
    end
    
    it 'should have a Money value that matches the money value that was initially persisted' do
      dummy = DummyMoney.first
      dummy.price.cents.should eq 123
    end
  end
  
  describe 'when accessing a document from the datastore with a Money datatype set as money with mass asignment' do
    before(:each) do
      DummyMoney.create(:description => "Test", :price => Money.parse('1.23'))
    end
    
    it 'should have a Money value that matches the money value that was initially persisted' do
      dummy = DummyMoney.first
      dummy.price.cents.should eq 123
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

  describe 'should handle currency' do
    it 'should have a Money value of 0' do
      DummyMoney.create(description: "Test", price: '1.23 RUB')
      dummy = DummyMoney.first
      dummy.price.currency.iso_code.should eq 'RUB'
      dummy.price.cents.should eq 123
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
  
  describe 'when accessing a document from the datastore with embedded documents with money fields' do
    before(:each) do
      o = DummyOrder.new(first_name: 'test')
      
      o.dummy_line_items << DummyLineItem.new({name: 'item 1', price: Money.new(1299)})
      li = DummyLineItem.new({name: 'item 2', price: Money.new(1499)})
      o.dummy_line_items.push li
      
      o.save
    end
    
    it 'should have correct value for first item' do
      o = DummyOrder.first
      o.dummy_line_items.first.price.should eq Money.parse('12.99')
    end
    
    it 'should have correct value for first item' do
      o = DummyOrder.first
      o.dummy_line_items.last.price.should eq Money.parse('14.99')
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