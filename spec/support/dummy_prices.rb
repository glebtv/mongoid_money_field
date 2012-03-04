class DummyPrices
  include Mongoid::Document
  include Mongoid::MoneyField
  
  field :description
  
  money_field :price1, :price2, :price3

end