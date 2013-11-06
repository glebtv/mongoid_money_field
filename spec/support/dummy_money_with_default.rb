# coding: utf-8

class DummyMoneyWithDefault
  include Mongoid::Document
  include Mongoid::MoneyField

  field :description

  money_field :price, default: 1.00
end