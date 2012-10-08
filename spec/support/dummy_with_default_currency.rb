# coding: utf-8

class DummyWithDefaultCurrency
  include Mongoid::Document
  include Mongoid::MoneyField

  field :description

  money_field :price, default_currency: 'EUR'
end