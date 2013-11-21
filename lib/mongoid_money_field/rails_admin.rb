require 'rails_admin/adapters/mongoid'
require 'rails_admin/config/fields/types/string'
module RailsAdmin
  module Adapters
    module Mongoid
      alias_method :type_lookup_without_money, :type_lookup
      def type_lookup(name, field)
        if field.type.to_s == 'Money' || field.type.class.name == 'MoneyType'
          { :type => :money_field }
        else
          type_lookup_without_money(name, field)
        end
      end
    end
  end

  module Config
    module Fields
      module Types
        class MoneyField < RailsAdmin::Config::Fields::Types::String
          # Register field type for the type loader
          RailsAdmin::Config::Fields::Types::register(self)

          register_instance_option :pretty_value do
            ret = if value.class.name == 'Hash' && value['cents']
              "%.2f" % ::Money.new(value['cents'], value['currency_iso']).to_f
            elsif value.respond_to?(:cents)
              "%.2f" % value.to_f
            else
              value
            end
          end

          register_instance_option :formatted_value do
            pretty_value
          end
        end
      end
    end
  end
end

