# coding: utf-8

require "money"

require "mongoid_money_field/type"
require "mongoid_money_field/version"
require "mongoid_money_field/field"

module Mongoid
  module MoneyField
    extend ActiveSupport::Concern

    module ClassMethods
      def money_field(*columns)
        opts = columns.last.is_a?(Hash) ? columns.pop : {}
        
        [columns].flatten.each do |name|
          field name, type: MoneyType.new(opts), default: opts[:default]
          if opts[:required]
            validates_presence_of name
          end
        end
      end
    end

  end
end

if Object.const_defined?("SimpleForm")
  require "mongoid_money_field/simple_form/money_input"
end