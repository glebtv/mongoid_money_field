# coding: utf-8

class DummyPositiveNumber
  include Mongoid::Document
  include Mongoid::MoneyField
  
  money_field :price

  validates_numericality_of :price, greater_than: 1, allow_nil: true
end