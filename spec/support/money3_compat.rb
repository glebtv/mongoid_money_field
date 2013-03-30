# coding: utf-8

class Money3
  include Mongoid::Document
  store_in collection: 'compat3'

  include Mongoid::MoneyField

  field :description

  field :price_currency, type: String
  field :price_cents, type: Integer
end

class Money3Compat
  include Mongoid::Document
  store_in collection: 'compat3'

  include Mongoid::MoneyField

  field :description

  money_field :price, default: 0
end