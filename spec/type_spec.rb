# coding: utf-8

require 'spec_helper'

describe MoneyType do
  context '#mongoize' do
    it "doesn't fail with BSON::Document on newer versions of bson gem" do
      doc = BSON::Document.new(cents: 1234, currency_iso: 'USD')

      allow(doc).to receive(:symbolize_keys!).and_raise(
        ArgumentError, "symbolize_keys! is not supported on BSON::Document instances. Please convert the document to hash first (using #to_h), then call #symbolize_keys! on the Hash instance"
      )

      expect(subject.mongoize(doc)).to eq({cents: 1234, currency_iso: 'USD'})
    end
  end
end
