# coding: utf-8

require 'spec_helper'

describe Money3Compat do
  it { should allow_mass_assignment_of(:description) }
  it { should allow_mass_assignment_of(:price) }

  it 'correctly reads old fields data' do
    Money3.create!(price_currency: 'GBP', price_cents: '12000')
    Money3Compat.first.price.cents.should eq 12000
    Money3Compat.first.price.currency.iso_code.should eq 'GBP'
  end

  it 'correctly works after save' do
    Money3.create!(price_currency: 'GBP', price_cents: '12000')
    Money3Compat.first.save.should be_true

    Money3Compat.first.price.cents.should eq 12000
    Money3Compat.first.price.currency.iso_code.should eq 'GBP'
  end

  it 'correctly migrates data' do
    Money3.create!(price_currency: 'GBP', price_cents: '12000')

    Money3.first.read_attribute(:price_currency).should_not be_nil
    Money3.first.read_attribute(:price_cents).should_not be_nil

    Money3.first.read_attribute(:price_currency).should eq 'GBP'
    Money3.first.read_attribute(:price_cents).should eq 12000

    Money3Compat.migrate_from_money_field_3!(:price)

    Money3Compat.first.price.cents.should eq 12000
    Money3Compat.first.price.currency.iso_code.should eq 'GBP'

    Money3.first.read_attribute(:price_currency).should be_nil
    Money3.first.read_attribute(:price_cents).should be_nil

    Money3Compat.first.read_attribute(:price_currency).should be_nil
    Money3Compat.first.read_attribute(:price_cents).should be_nil

    f = Money3Compat.first
    f.price = '32.00 GBP'
    f.save.should be_true

    Money3Compat.first.price.cents.should eq 3200
    Money3Compat.first.price.currency.iso_code.should eq 'GBP'
  end

  describe 'with fixed currency' do
    it 'correctly reads old' do
      Money3.create!(price_with_fix_cents: '12000')
      Money3Compat.first.price_with_fix.cents.should eq 12000
      Money3Compat.first.price_with_fix.currency.iso_code.should eq 'GBP'
    end

    it 'correctly works after save' do
      Money3.create!(price_with_fix_cents: '12000')
      Money3Compat.first.save.should be_true
      Money3Compat.first.price_with_fix.cents.should eq 12000
      Money3Compat.first.price_with_fix.currency.iso_code.should eq 'GBP'
    end

    it 'correctly migrates data' do
      Money3.create!(price_with_fix_cents: '12000')
      Money3Compat.migrate_from_money_field_3!(:price_with_fix)

      Money3Compat.first.read_attribute(:price_with_fix_currency).should be_nil
      Money3Compat.first.read_attribute(:price_with_fix_cents).should be_nil

      Money3Compat.first.price_with_fix.cents.should eq 12000
      Money3Compat.first.price_with_fix.currency.iso_code.should eq 'GBP'
    end
  end

  describe 'with no default' do
    it 'correctly reads old' do
      Money3.create!(price_no_default_currency: 'GBP', price_no_default_cents: '12000')
      Money3Compat.first.price_no_default.cents.should eq 12000
      Money3Compat.first.price_no_default.currency.iso_code.should eq 'GBP'
    end

    it 'correctly works after save' do
      Money3.create!(price_no_default_currency: 'GBP', price_no_default_cents: '12000')
      Money3Compat.first.save.should be_true
      Money3Compat.first.price_no_default.cents.should eq 12000
      Money3Compat.first.price_no_default.currency.iso_code.should eq 'GBP'
    end

    it 'correctly migrates data' do
      Money3.create!(price_no_default_currency: 'GBP', price_no_default_cents: '12000')
      Money3Compat.migrate_from_money_field_3!(:price_no_default)

      Money3Compat.first.read_attribute(:price_no_default_currency).should be_nil
      Money3Compat.first.read_attribute(:price_no_default_cents).should be_nil

      Money3Compat.first.price_no_default.cents.should eq 12000
      Money3Compat.first.price_no_default.currency.iso_code.should eq 'GBP'
    end

    it 'correctly migrates data with no currency' do
      Money3.create!(price_no_default_cents: '12000')
      Money3Compat.migrate_from_money_field_3!(:price_no_default)

      Money3Compat.first.read_attribute(:price_no_default_currency).should be_nil
      Money3Compat.first.read_attribute(:price_no_default_cents).should be_nil

      Money3Compat.first.price_no_default.cents.should eq 12000
      Money3Compat.first.price_no_default.currency.iso_code.should eq 'RUB'
    end

    it 'correctly migrates data with no cents' do
      Money3.create!()
      Money3Compat.migrate_from_money_field_3!(:price_no_default)

      Money3Compat.first.read_attribute(:price_no_default_currency).should be_nil
      Money3Compat.first.read_attribute(:price_no_default_cents).should be_nil

      Money3Compat.first.price_no_default.should be_nil
    end
  end
end