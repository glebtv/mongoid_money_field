#encoding: utf-8

require 'money'

module Mongoid
  module MoneyField
    extend ActiveSupport::Concern
    
    included do
    end

    module ClassMethods

      def money_field( *columns )
        opts = columns.last.is_a?( Hash ) ? columns.pop : {}
        opts = {
          fixed_currency: nil,
          default: nil,
          required: false,
          default_currency: nil
        }.merge( opts )

        [ columns ].flatten.each do |name|
          default, default_cents = nil, nil

          name = name.to_s

          unless opts[:default].nil?
            default = Money.parse( opts[:default] )
            default_cents = default.cents
          end

          attr_cents            = name + '_cents'
          attr_currency         = name + '_currency'
          attr_plain            = name + '_plain'
          attr_before_type_cast = name + '_before_type_cast'

          field attr_cents, type: Integer, default: default_cents

          attr_accessible attr_plain, name

          if opts[:required]
            validates_presence_of name
          end

          if opts[:fixed_currency].nil?
            default_currency = nil

            if opts[:default_currency].nil?
              default_currency = default.currency.iso_code unless default.nil?
            else
              default_currency = opts[:default_currency]
            end

            field attr_currency, type: String, default: default_currency

            if default_currency.nil?
              before_save do
                self[ attr_currency ] ||= Money.default_currency.iso_code
              end
            end
          end

          define_method( attr_before_type_cast ) do
            code = ( opts[:fixed_currency].nil? ? read_attribute( attr_currency ) : opts[:fixed_currency] ) 
            currency = Money::Currency.find( code ) || Money.default_currency

            value = self.send( attr_plain )

            return if value.nil?

            value.gsub( currency.thousands_separator, '' ).gsub( currency.decimal_mark, '.' )
          end

          define_method( name ) do
            cents = read_attribute( attr_cents )

            code = opts[:fixed_currency].nil? ? read_attribute( attr_currency ) : opts[:fixed_currency]

            cents.nil? ? nil : Money.new( cents, code || ::Money.default_currency )
          end
          
          define_method( attr_plain ) do
            value = instance_variable_get( "@#{attr_plain}".to_sym )
            value = self.send( name ) if value.nil?
            value = value.format( symbol: false, no_cents_if_whole: true ) if value.is_a?( Money )

            value
          end
          
          define_method( "#{attr_plain}=" ) do |value|
            instance_variable_set( "@#{attr_plain}".to_sym, value )

            if value.blank?
              write_attribute( attr_cents, nil )
              write_attribute( attr_currency, nil ) if opts[:fixed_currency].nil?
              
              return
            end

            if opts[:default_currency].nil?
              money = value.to_money

            else
              old_default = Money.default_currency
              Money.default_currency = Money::Currency.new( opts[:default_currency] )
              money = value.to_money
              Money.default_currency = old_default
            end

            write_attribute( attr_cents, money.cents )
            write_attribute( attr_currency, money.currency.iso_code ) if opts[:fixed_currency].nil?            
          end

          define_method( "#{name}=" ) do |value|
            self.send( "#{attr_plain}=", value )
          end
        end
      end
    end
  end
end

if Object.const_defined?("SimpleForm")
  require "mongoid_money_field/simple_form/money_input"
end