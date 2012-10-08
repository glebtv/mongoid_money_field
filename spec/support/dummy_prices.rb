# coding: utf-8

class DummyPrices
  include Mongoid::Document
  include Mongoid::MoneyField
  
  field :description
  
  money_field :price1, default: 0
  money_field :price2, :price3

  money_field :price, default: 1.00
end