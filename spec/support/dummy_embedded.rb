class DummyOrder
  include Mongoid::Document
  embeds_many :dummy_line_items
  field :first_name
end

class DummyLineItem
  include Mongoid::Document
  include Mongoid::MoneyField
  
  field :name
  money_field :price

end