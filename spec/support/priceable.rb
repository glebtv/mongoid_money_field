class Priceable
  include Mongoid::Document

  field :price, :type => MoneyType.new
end
