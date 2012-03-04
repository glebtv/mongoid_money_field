require 'money'

module Mongoid
  module MoneyField
    extend ActiveSupport::Concern
    included do

    end

    module ClassMethods
      def money_field(*columns)
        [columns].flatten.each do |name|
          attr_cents = (name.to_s + '_cents').to_sym
          attr_currency = (name.to_s + '_currency').to_sym

          field attr_cents,    type: Integer, default: 0
          field attr_currency, type: String,  default: ::Money.default_currency.iso_code

          define_method(name) do
            cents    = read_attribute(attr_cents)
            currency = read_attribute(attr_currency)

            Money.new(cents || 0, currency || ::Money.default_currency)
          end

          define_method("#{name}=") do |value|
            if value.blank?
              write_attribute(attr_cents,    nil)
              write_attribute(attr_currency, nil)
              nil
            else
              money = value.to_money
              write_attribute(attr_cents,    money.cents)
              write_attribute(attr_currency, money.currency.iso_code)
              money
            end
          end
        end
      end
    end
  end
end
