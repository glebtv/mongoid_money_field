class Money3
  include Mongoid::Document
  store_in collection: 'compat3'

  include Mongoid::MoneyField

  field :description

  field :price_currency, type: String
  field :price_cents, type: Integer

  field :price_no_default_currency, type: String
  field :price_no_default_cents, type: Integer

  field :price_with_fix_currency, type: String
  field :price_with_fix_cents, type: Integer
end

class Money3Compat
  include Mongoid::Document
  store_in collection: 'compat3'

  include Mongoid::MoneyField

  field :description

  money_field :price, default: 0
  money_field :price_no_default
  money_field :price_with_fix, fixed_currency: 'GBP'
end
