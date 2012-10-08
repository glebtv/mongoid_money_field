class DummyMoneyWithoutDefault
  include Mongoid::Document
  include Mongoid::MoneyField
  
  field :description
  
  money_field_without_default :price

end