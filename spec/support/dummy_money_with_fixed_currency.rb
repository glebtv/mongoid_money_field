# coding: utf-8

class DummyMoneyWithFixedCurrency
  include Mongoid::Document
  include Mongoid::MoneyField

  field :description

  money_field :price, fixed_currency: 'GBP'
end