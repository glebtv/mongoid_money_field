#encoding: utf-8

require "money"
require "mongoid_money_field/version"
require "mongoid_money_field/field"

module Mongoid
  module MoneyField
    extend ActiveSupport::Concern

    module ClassMethods
      def money_field(*columns)
        opts = columns.last.is_a?( Hash ) ? columns.pop : {}
        opts = {
            fixed_currency: nil,
            default: nil,
            required: false,
            default_currency: nil
        }.merge( opts )

        ensure_default = Proc.new do |currency|
          if opts[:fixed_currency].nil?
            if currency.nil?
              if opts[:default_currency].nil?
                Money.default_currency
              else
                opts[:default_currency]
              end
            else
              currency
            end
          else
            opts[:fixed_currency]
          end
        end

        [columns].flatten.each do |name|
          default = nil
          name = name.to_s
          unless opts[:default].nil?
            default = Money.parse(opts[:default])
          end

          field name, type: Money, default: default
          validates_presence_of name if opts[:required]

          define_method("#{name}=") do |value|
            instance_variable_set( "@#{name}_before_type_cast".to_sym, value)

            if value.blank?
              write_attribute(name, nil)
            else
              if opts[:default_currency].nil?
                money = value.to_money
              else
                old_default = Money.default_currency
                Money.default_currency = Money::Currency.new(opts[:default_currency])
                money = value.to_money
                Money.default_currency = old_default
              end

              unless opts[:fixed_currency].nil?
                money = Money.new(money.cents, opts[:fixed_currency])
              end

              write_attribute(name, money)
              remove_attribute("#{name}_currency")
              remove_attribute("#{name}_cents")
            end
          end

          # mongoid money field 2 compat
          define_method(name) do
            if read_attribute("#{name}_cents").nil?
              value = read_attribute(name)
              if value.nil?
                nil
              else
                if value.is_a?(Hash)
                  value[:currency_iso] = ensure_default.call(value[:currency_iso])
                end
                Money.demongoize(value)
              end

            else
              currency = read_attribute("#{name}_currency")
              currency = ensure_default.call(currency)
              Money.new(read_attribute("#{name}_cents"), currency)
            end
          end

          define_method("#{name}_before_type_cast") do
            instance_variable_get( "@#{name}_before_type_cast".to_sym) || send(name).to_s
          end

          # deprecated
          define_method("migrate_#{name}_from_money_3!") do
            cents = read_attribute("#{name}_cents")
            if cents.nil?
              send("#{name}=", nil)
            else
              currency = read_attribute("#{name}_currency")

              if currency.nil?
                if opts[:default_currency].nil?
                  currency = Money.default_currency
                else
                  currency = opts[:default_currency]
                end
              end

              unless opts[:fixed_currency].nil?
                currency = opts[:fixed_currency]
              end
              send("#{name}=", Money.new(cents, currency))
            end
          end

          # deprecated
          define_method("#{name}_cents") do
            send(name).nil? ? 0 : send(name).cents
          end

          # deprecated
          define_method("#{name}_currency") do
            if opts[:fixed_currency].nil?
              send(name).nil? ? Money.default_currency : send(name).currency.iso_code
            else
              opts[:fixed_currency]
            end
          end

          # deprecated
          define_method("#{name}_cents=") do |val|
            send("#{name}=", Money.new(val, send("#{name}_currency")))
          end

          # deprecated
          define_method("#{name}_currency=") do |val|
            send("#{name}=", Money.new(send("#{name}_cents"), val))
          end

          # deprecated
          define_method("#{name}_plain=") do |val|
            send("#{name}=", val)
          end
          # deprecated
          define_method("#{name}_plain") do |val|
            send("#{name}")
          end
        end
      end

      def migrate_from_money_field_3!(*columns)
        each do |val|
          [columns].flatten.each do |name|
            val.send("migrate_#{name.to_s}_from_money_3!")
            val.save!
          end
        end
      end
    end
  end
end

if Object.const_defined?("SimpleForm")
  require "mongoid_money_field/simple_form/money_input"
end