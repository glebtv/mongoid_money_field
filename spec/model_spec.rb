# coding: utf-8

require 'spec_helper'

describe DummyMoney do
  it { is_expected.to allow_mass_assignment_of(:description) }
  it { is_expected.to allow_mass_assignment_of(:price) }
end