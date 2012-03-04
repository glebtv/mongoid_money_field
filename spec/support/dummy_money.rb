class DummyMoney
  include Mongoid::Document
  include Mongoid::MoneyField
  
  field :description
  
  money_field :price

end