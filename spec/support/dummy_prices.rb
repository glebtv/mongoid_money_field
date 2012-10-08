class DummyPrices
  include Mongoid::Document
  include Mongoid::MoneyField
  
  field :description
  
  money_field :price1, :price2, :price3

  money_field_with_options :price, default: 1.00
end