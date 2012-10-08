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

    it 'should be possible to set value to nil' do
      dummy = DummyMoney.new
      dummy.price = Money.parse(1.23)
      dummy.save.should eq true

      dummy = DummyMoney.first
      dummy.price.should eq Money.parse(1.23)
      dummy.price = nil
      dummy.save.should eq true
      dummy = DummyMoney.first
      dummy.price.should be_nil
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
    it 'should be nil' do
      dummy = DummyMoney.new
      dummy.save.should eq true
      DummyMoney.first.price.should be_nil
    end

    it 'should set money to default currency if money is given without it' do
      dummy = DummyMoneyWithDefault.new
      dummy.save.should eq true
      dummy = DummyMoneyWithDefault.first
      dummy.price.currency.iso_code.should eq Money.default_currency.iso_code
      dummy.price.cents.should eq 100
    end

    it 'should set money to default currency if money is given without it on a document with multiple money fields' do
      dummy = DummyPrices.new
      dummy.save.should eq true
      dummy = DummyPrices.first
      dummy.price.currency.iso_code.should eq Money.default_currency.iso_code
      dummy.price.cents.should eq 100

      dummy.price1.should be_nil
    end


    it 'should set money to correct currency if money is given with it' do
      dummy = DummyMoneyWithDefaultWithCurrency.new
      dummy.save.should eq true
      dummy = DummyMoneyWithDefaultWithCurrency.first
      dummy.price.currency.iso_code.should eq 'GBP'
      dummy.price.cents.should eq 100
    end
  end


  describe 'when accessing a document from the datastore with a Money datatype and fixed currency' do
    it 'should have correct currency when value is set to 5$' do
      DummyMoneyWithFixedCurrency.create!(price: '5$')
      dummy = DummyMoneyWithFixedCurrency.first
      dummy.price.currency.iso_code.should eq 'GBP'
      dummy.price.cents.should eq 500
      dummy.price.should eq Money.parse('5 GBP')
    end

    it 'should have correct currency when value is set to 100 RUB' do
      DummyMoneyWithFixedCurrency.create!(price: '100 RUB')
      dummy = DummyMoneyWithFixedCurrency.first
      dummy.price.currency.iso_code.should eq 'GBP'
      dummy.price.cents.should eq 100_00
      dummy.price.should eq Money.parse('100 GBP')
    end
  end

  describe 'when setting to a string value with currency' do
    it 'should handle RUB' do
      DummyMoney.create(description: "Test", price: '1.23 RUB')
      dummy = DummyMoney.first
      dummy.price.currency.iso_code.should eq 'RUB'
      dummy.price.cents.should eq 123
      dummy.price.should eq Money.parse('1.23 RUB')
    end

    it 'should handle $' do
      DummyMoney.create(description: "Test", price: '1.23 USD')
      dummy = DummyMoney.first
      dummy.price.currency.iso_code.should eq 'USD'
      dummy.price.cents.should eq 123
      dummy.price.should eq Money.parse('1.23 USD')
    end
  end
  
  describe 'when accessing a document from the datastore with a Money datatype and blank value' do
    before(:each) do
      DummyMoney.create(description: "Test", price: '')
    end
    
    it 'should be nil' do
      dummy = DummyMoney.first
      dummy.price.should be_nil
    end

    it 'should be updated correctly' do
      dummy = DummyMoney.first
      dummy.price.should be_nil
      dummy.price = '1.23 USD'
      dummy.save.should eq true
      dummy = DummyMoney.first
      dummy.price.currency.iso_code.should eq 'USD'
      dummy.price.cents.should eq 123
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