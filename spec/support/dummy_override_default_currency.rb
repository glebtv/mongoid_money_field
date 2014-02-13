# coding: utf-8

class DummyOverrideDefaultCurrency
  include Mongoid::Document
  include Mongoid::MoneyField

  field :description

  money_field :price, required: true, default_currency: 'RUB', fixed_currency: 'GBP'
end