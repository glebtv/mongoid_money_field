# coding: utf-8

class DummyMoneyRequired
  include Mongoid::Document
  include Mongoid::MoneyField

  field :description

  money_field :price, required: true, default_currency: nil
end