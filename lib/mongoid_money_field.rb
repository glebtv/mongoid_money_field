# coding: utf-8

require 'money'

module Mongoid
  module MoneyField
    extend ActiveSupport::Concern
    included do

    end

    module ClassMethods

      def money_field_with_options(columns, opts = {})
        [columns].flatten.each do |name|
          opts = {fixed_currency: nil, default: nil}.merge(opts)

          if opts[:default].nil?
            default = nil
            default_currency = ::Money.default_currency.iso_code if opts[:fixed_currency].nil?
          else
            default_money = Money.parse(opts[:default])
            default = default_money.cents
            default_currency = default_money.currency.iso_code if opts[:fixed_currency].nil?
          end

          attr_cents = (name.to_s + '_cents').to_sym
          field attr_cents, type: Integer, default: default

          if opts[:fixed_currency].nil?
            attr_currency = (name.to_s + '_currency').to_sym
            field attr_currency, type: String,  default: default_currency
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
              money = value.to_money
              write_attribute(attr_cents, money.cents)
              if opts[:fixed_currency].nil?
                write_attribute(attr_currency, money.currency.iso_code)
              end
              money
            end
          end
        end
      end

      def money_field(*columns)
        money_field_with_options(columns, default: 0)
      end
      
      def money_field_without_default(*columns)
        money_field_with_options(columns)
      end
    end
  end
end
