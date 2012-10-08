# coding: utf-8

class DummyMoneyWithoutDefault
  include Mongoid::Document
  include Mongoid::MoneyField
  
  field :description
  
  money_field :price

end