# coding: utf-8

require 'spec_helper'

describe Money3Compat do
  it { is_expected.to allow_mass_assignment_of(:description) }
  it { is_expected.to allow_mass_assignment_of(:price) }

  it 'correctly reads old fields data' do
    Money3.create!(price_currency: 'GBP', price_cents: '12000')
    expect(Money3Compat.first.price.cents).to eq 12000
    expect(Money3Compat.first.price.currency.iso_code).to eq 'GBP'
  end

  it 'correctly works after save' do
    Money3.create!(price_currency: 'GBP', price_cents: '12000')
    expect(Money3Compat.first.save).to be_truthy

    expect(Money3Compat.first.price.cents).to eq 12000
    expect(Money3Compat.first.price.currency.iso_code).to eq 'GBP'
  end

  it 'correctly migrates data' do
    Money3.create!(price_currency: 'GBP', price_cents: '12000')

    expect(Money3.first.read_attribute(:price_currency)).not_to be_nil
    expect(Money3.first.read_attribute(:price_cents)).not_to be_nil

    expect(Money3.first.read_attribute(:price_currency)).to eq 'GBP'
    expect(Money3.first.read_attribute(:price_cents)).to eq 12000

    Money3Compat.migrate_from_money_field_3!(:price)

    expect(Money3Compat.first.price.cents).to eq 12000
    expect(Money3Compat.first.price.currency.iso_code).to eq 'GBP'

    expect(Money3.first.read_attribute(:price_currency)).to be_nil
    expect(Money3.first.read_attribute(:price_cents)).to be_nil

    expect(Money3Compat.first.read_attribute(:price_currency)).to be_nil
    expect(Money3Compat.first.read_attribute(:price_cents)).to be_nil

    f = Money3Compat.first
    f.price = '32.00 GBP'
    expect(f.save).to be_truthy

    expect(Money3Compat.first.price.cents).to eq 3200
    expect(Money3Compat.first.price.currency.iso_code).to eq 'GBP'
  end

  describe 'with fixed currency' do
    it 'correctly reads old' do
      Money3.create!(price_with_fix_cents: '12000')
      expect(Money3Compat.first.price_with_fix.cents).to eq 12000
      expect(Money3Compat.first.price_with_fix.currency.iso_code).to eq 'GBP'
    end

    it 'correctly works after save' do
      Money3.create!(price_with_fix_cents: '12000')
      expect(Money3Compat.first.save).to be_truthy
      expect(Money3Compat.first.price_with_fix.cents).to eq 12000
      expect(Money3Compat.first.price_with_fix.currency.iso_code).to eq 'GBP'
    end

    it 'correctly migrates data' do
      Money3.create!(price_with_fix_cents: '12000')
      Money3Compat.migrate_from_money_field_3!(:price_with_fix)

      expect(Money3Compat.first.read_attribute(:price_with_fix_currency)).to be_nil
      expect(Money3Compat.first.read_attribute(:price_with_fix_cents)).to be_nil

      expect(Money3Compat.first.price_with_fix.cents).to eq 12000
      expect(Money3Compat.first.price_with_fix.currency.iso_code).to eq 'GBP'
    end
  end

  describe 'with no default' do
    it 'correctly reads old' do
      Money3.create!(price_no_default_currency: 'GBP', price_no_default_cents: '12000')
      expect(Money3Compat.first.price_no_default.cents).to eq 12000
      expect(Money3Compat.first.price_no_default.currency.iso_code).to eq 'GBP'
    end

    it 'correctly works after save' do
      Money3.create!(price_no_default_currency: 'GBP', price_no_default_cents: '12000')
      expect(Money3Compat.first.save).to be_truthy
      expect(Money3Compat.first.price_no_default.cents).to eq 12000
      expect(Money3Compat.first.price_no_default.currency.iso_code).to eq 'GBP'
    end

    it 'correctly migrates data' do
      Money3.create!(price_no_default_currency: 'GBP', price_no_default_cents: '12000')
      Money3Compat.migrate_from_money_field_3!(:price_no_default)

      expect(Money3Compat.first.read_attribute(:price_no_default_currency)).to be_nil
      expect(Money3Compat.first.read_attribute(:price_no_default_cents)).to be_nil

      expect(Money3Compat.first.price_no_default.cents).to eq 12000
      expect(Money3Compat.first.price_no_default.currency.iso_code).to eq 'GBP'
    end

    it 'correctly migrates data with no currency' do
      Money3.create!(price_no_default_cents: '12000')
      Money3Compat.migrate_from_money_field_3!(:price_no_default)

      expect(Money3Compat.first.read_attribute(:price_no_default_currency)).to be_nil
      expect(Money3Compat.first.read_attribute(:price_no_default_cents)).to be_nil

      expect(Money3Compat.first.price_no_default.cents).to eq 12000
      expect(Money3Compat.first.price_no_default.currency.iso_code).to eq 'RUB'
    end

    it 'correctly migrates data with no cents' do
      Money3.create!()
      Money3Compat.migrate_from_money_field_3!(:price_no_default)

      expect(Money3Compat.first.read_attribute(:price_no_default_currency)).to be_nil
      expect(Money3Compat.first.read_attribute(:price_no_default_cents)).to be_nil

      expect(Money3Compat.first.price_no_default).to be_nil
    end
  end
end