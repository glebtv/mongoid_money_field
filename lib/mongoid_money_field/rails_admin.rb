require 'rails_admin/adapters/mongoid'
begin
  require 'rails_admin/adapters/mongoid/property'
rescue Exception => e 
end

module RailsAdmin
  module Adapters
    module Mongoid
      class Property
        alias_method :type_without_money_field, :type
        def type
          if property.type.to_s == 'Money' || property.type.class.name == 'MoneyType'
            :money_field
          else
            type_without_money_field
          end
        end
      end
    end
  end
end

require 'rails_admin/config/fields/types/string'
module RailsAdmin
  module Config
    module Fields
      module Types
        class MoneyField < RailsAdmin::Config::Fields::Types::String
          # Register field type for the type loader
          RailsAdmin::Config::Fields::Types::register(self)

          register_instance_option :pretty_value do
            ret = if (value.class.name == 'Hash' || value.class.name == 'BSON::Document') && value['cents']
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
