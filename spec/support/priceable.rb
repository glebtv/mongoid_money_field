class Priceable
  include Mongoid::Document

  field :price, :type => Money
end