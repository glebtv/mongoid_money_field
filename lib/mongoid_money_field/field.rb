# coding: utf-8
# from https://github.com/RubyMoney/money-rails/blob/master/lib/money-rails/mongoid/money.rb

class Money
  # Converts an object of this instance into a database friendly value.
  def mongoize
    {
        :cents => cents,
        :currency_iso => currency.iso_code
    }
  end

  class << self

    # Get the object as it was stored in the database, and instantiate
    # this custom class from it.
    def demongoize(object)
      case
      when object.is_a?(BSON::Document) then
        object.has_key?(:cents) ? ::Money.new(object[:cents], object[:currency_iso]) : nil
      when object.is_a?(Hash) then
        object = object.symbolize_keys
        object.has_key?(:cents) ? ::Money.new(object[:cents], object[:currency_iso]) : nil
      else
        nil
      end
    end

    # Takes any possible object and converts it to how it would be
    # stored in the database.
    def mongoize(object)
      case
        when object.is_a?(Money) then object.mongoize
        when object.is_a?(BSON::Document) then
          ::Money.new(object[:cents], object[:currency_iso]).mongoize
        when object.is_a?(Hash) then
          object.symbolize_keys! if object.respond_to?(:symbolize_keys!)
          ::Money.new(object[:cents], object[:currency_iso]).mongoize
        when object.respond_to?(:to_money) then
          object.to_money.mongoize
        else object
      end
    end

    # Converts the object that was supplied to a criteria and converts it
    # into a database friendly form.
    def evolve(object)
      case object
        when Money then object.mongoize
        else object
      end
    end
  end
end

