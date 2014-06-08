# coding: utf-8

require 'spec_helper'

# from https://github.com/RubyMoney/money-rails/blob/master/spec/mongoid/three_spec.rb

describe Money do
  let!(:priceable) { Priceable.create(:price => Money.new(100, 'EUR')) }
  let!(:priceable_from_num) { Priceable.create(:price => 1) }
  let!(:priceable_from_string) { Priceable.create(:price => '1 EUR' )}
  let!(:priceable_from_hash) { Priceable.create(:price => {:cents=>100, :currency_iso=>"EUR"} )}
  let!(:priceable_from_hash_with_indifferent_access) {
    Priceable.create(:price => {:cents=>100, :currency_iso=>"EUR"}.with_indifferent_access)
  }

  context "mongoize" do
    it "mongoizes correctly a Money object to a hash of cents and currency" do
      expect(priceable.price.cents).to eq(100)
      expect(priceable.price.currency).to eq(Money::Currency.find('EUR'))
    end

    it "mongoizes correctly a Numeric object to a hash of cents and currency" do
      expect(priceable_from_num.price.cents).to eq(100)
      expect(priceable_from_num.price.currency).to eq(Money.default_currency)
    end

    it "mongoizes correctly a String object to a hash of cents and currency" do
      expect(priceable_from_string.price.cents).to eq(100)
      expect(priceable_from_string.price.currency).to eq(Money::Currency.find('EUR'))
    end

    it "mongoizes correctly a hash of cents and currency" do
      expect(priceable_from_hash.price.cents).to eq(100)
      expect(priceable_from_hash.price.currency).to eq(Money::Currency.find('EUR'))
    end

    it "mongoizes correctly a HashWithIndifferentAccess of cents and currency" do
      expect(priceable_from_hash_with_indifferent_access.price.cents).to eq(100)
      expect(priceable_from_hash_with_indifferent_access.price.currency).to eq(Money::Currency.find('EUR'))
    end
  end

  context "demongoize" do
    subject { Priceable.first.price }
    it { is_expected.to be_an_instance_of(Money) }
    it { is_expected.to eq(Money.new(100, 'EUR')) }
    it "returns nil if a nil value was stored" do
      nil_priceable = Priceable.create(:price => nil)
      expect(nil_priceable.price).to be_nil
    end
    it 'returns nil if an unknown value was stored' do
      zero_priceable = Priceable.create(:price => [])
      expect(zero_priceable.price).to be_nil
    end
  end

  context "evolve" do
    it "transforms correctly a Money object to a Mongo friendly value" do
      expect(Priceable.where(:price => Money.new(100, 'EUR')).first).to eq(priceable)
    end
  end
end