class DummyMoneyWithFixedCurrency
  include Mongoid::Document
  include Mongoid::MoneyField

  field :description

  money_field_with_options :price, fixed_currency: 'GBP'
end