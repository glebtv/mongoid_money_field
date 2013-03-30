== mongoid money field

{<img src="https://secure.travis-ci.org/glebtv/mongoid_money_field.png" alt="Build Status" />}[http://travis-ci.org/glebtv/mongoid_money_field]
{<img src="https://gemnasium.com/glebtv/mongoid_money_field.png" alt="Dependency Status" />}[https://gemnasium.com/glebtv/mongoid_money_field]

This is a super simple gem to use RubyMoney money type columns with mongoid

https://github.com/RubyMoney/money

https://github.com/mongoid/mongoid

== Description

A simple gem that creates a Money datatype using RubyMoney for Mongoid.

Inspired by https://gist.github.com/840500

== Updating
v3 breaks backwards compatibility in favour of having syntax and defaults similar to field mongoid macro

To get the same behaviour as 1.0 please add "default: 0" to field declaration, like this

    money_field :price, default: 0

please avoid using v2, i realized that API was stupid after commiting it.

== Installation

Include the gem in your Gemfile

    gem 'mongoid_money_field'

== Usage

    class DummyMoney
      include Mongoid::Document
      include Mongoid::MoneyField
      
      field :description

      # defaults to 0
      money_field :cart_total, default: 0

      # defaults to nil
      money_field :price, :old_price, default: nil # defaults to nil

      # to disallow changing currency (and to not store it in database)
      money_field :price2, fixed_currency: 'GBP'

      # set a default
      money_field :price3, default: '1.23 RUB'

      # make required
      money_field :price4, required: true, default_currency: nil

      # default_currency is Money.default_currency.iso_code if not specified
      # fixed_currency overrides default_currency if set

      # field can be validated as numeric value (with localized separators)
      validates_numericality_of :price, greater_than: 0
    end

    simple_form_for do |f|
      f.input :price, as: :money
    end

All Money values are converted and stored in mongo as cents and currency in two separate fields.

== Finding by price

DummyMoney.where(price_cents: 123).first

== Copyright

Copyright (c) 2012-2013 glebtv (http://rocketscience.pro). MIT License.

