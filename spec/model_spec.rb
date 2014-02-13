# coding: utf-8

require 'spec_helper'

describe DummyMoney do
  it { should allow_mass_assignment_of(:description) }
  it { should allow_mass_assignment_of(:price) }
end