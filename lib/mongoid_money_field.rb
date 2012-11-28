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

        @@logger ||= Logger.new( File.join( Rails.root, 'log', 'mongoid_money_field.log' ) )
        @@logger.info( Time.now.strftime('%Y.%m.%d %H:%M:%S') )

        [ columns ].flatten.each do |name|
          default, default_cents = nil, nil

          name = name.to_s

          @@logger.info( 'Start defining ' + name )

          unless opts[:default].nil?
            default = Money.parse( opts[:default] )
            default_cents = default.cents
          end

          attr_cents            = name + '_cents'
          attr_currency         = name + '_currency'
          attr_plain            = name + '_plain'
          attr_before_type_cast = name + '_before_type_cast'

          field attr_cents, type: Integer, default: default_cents

          attr_accessible attr_plain
          
          if opts[:fixed_currency].nil?
            default_currency = nil

            if opts[:default_currency].nil?
              default_currency = default.currency.iso_code unless default.nil?
            else
              default_currency = opts[:default_currency]
            end

            field attr_currency, type: String, default: default_currency
          end

          define_method( attr_before_type_cast ) do
            @@logger.info( attr_before_type_cast )

            code = ( opts[:fixed_currency].nil? ? read_attribute( attr_currency ) : opts[:fixed_currency] ) 
            currency = Money::Currency.find( code ) || Money.default_currency

            value = self.send( attr_plain )

            value = value.gsub( currency.thousands_separator, '' ).gsub( currency.decimal_mark, '.' )
          end

          define_method( name ) do
            @@logger.info( name )

            cents = read_attribute( attr_cents )

            code = opts[:fixed_currency].nil? ? read_attribute( attr_currency ) : opts[:fixed_currency]

            cents.nil? ? nil : Money.new( cents, code || ::Money.default_currency )
          end
          
          define_method( attr_plain ) do
            @@logger.info( attr_plain )

            value = instance_variable_get( "@#{attr_plain}".to_sym )
            value = self.send( name ) if value.nil?
            value = value.format( symbol: false, no_cents_if_whole: true ) if value.is_a?( Money )

            value
          end
          
          define_method( "#{attr_plain}=" ) do |value|
            @@logger.info( "#{attr_plain}=" )

            instance_variable_set( "@#{attr_plain}".to_sym, value )

            if value.blank?
              write_attribute( attr_cents, nil )
              write_attribute( attr_currency, nil ) if opts[:fixed_currency].nil?
              
              return
            end

            value = self.send( attr_before_type_cast )

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
            @@logger.info( "#{name}=" )

            self.send( "#{attr_plain}=", value )
          end

          @@logger.info( "End defining " + name )
        end
      end
    end
  end
end

class MoneyInput < SimpleForm::Inputs::Base
  enable :placeholder, :min_max

  def input
    add_size!
    input_html_classes.unshift("numeric")
    if html5?
      input_html_options[:type] ||= "number"
      input_html_options[:step] ||= integer? ? 1 : "any"
    end
    @builder.text_field("#{attribute_name}_plain", input_html_options)
  end

  private

  # Rails adds the size attr by default, if the :size key does not exist.
  def add_size!
    input_html_options[:size] ||= nil
  end
end