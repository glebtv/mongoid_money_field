# coding: utf-8

class DummyNotANumber
  include Mongoid::Document
  include Mongoid::MoneyField
  
  money_field :price

  validates_numericality_of :price
end