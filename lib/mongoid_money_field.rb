# coding: utf-8

require 'money'

module Mongoid
  module MoneyField
    extend ActiveSupport::Concern
    included do

    end

    module ClassMethods

      def money_field(*columns)
        opts = columns.last.is_a?(Hash) ? columns.pop : {}
        opts = {
            fixed_currency: nil,
            default: nil,
            required: false,
            default_currency: nil
        }.merge(opts)

        [columns].flatten.each do |name|
          default_money = nil

          if opts[:default].nil?
            default = nil
          else
            default_money = Money.parse(opts[:default])
            default = default_money.cents
          end

          attr_cents = (name.to_s + '_cents').to_sym
          attr_currency = (name.to_s + '_currency').to_sym

          field attr_cents, type: Integer, default: default
          if opts[:fixed_currency].nil?
            default_currency = nil
            if opts[:default_currency].nil?
              unless default_money.nil?
                default_currency = default_money.currency.iso_code
              end
            else
              default_currency = opts[:default_currency]
            end

            field attr_currency, type: String, default: default_currency
          end

          if opts[:required]
            validate do
              cents = read_attribute(attr_cents)

              if cents.nil?
                errors.add(name, errors.generate_message(name, :error, default: "invalid value for #{name}"))
              end
              if opts[:fixed_currency].nil? && read_attribute(attr_currency).nil?
                errors.add(name, errors.generate_message(name, :error, default: "invalid value for #{name} currency"))
              end
            end
          end


          define_method(name) do
            cents = read_attribute(attr_cents)

            if opts[:fixed_currency].nil?
              currency = read_attribute(attr_currency)
            else
              currency = opts[:fixed_currency]
            end

            if cents.nil?
              nil
            else
              Money.new(cents, currency || ::Money.default_currency)
            end
          end

          define_method("#{name}=") do |value|
            if value.blank?
              write_attribute(attr_cents, nil)
              if opts[:fixed_currency].nil?
                write_attribute(attr_currency, nil)
              end
              nil
            else
              if opts[:default_currency].nil?
                money = value.to_money
              else
                old_default = Money.default_currency
                Money.default_currency = Money::Currency.new(opts[:default_currency])
                money = value.to_money
                Money.default_currency = old_default
              end

              write_attribute(attr_cents, money.cents)
              if opts[:fixed_currency].nil?
                write_attribute(attr_currency, money.currency.iso_code)
              end
              money
            end
          end
        end
      end
    end
  end
end
