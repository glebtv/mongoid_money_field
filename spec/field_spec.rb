# coding: utf-8

require 'spec_helper'

describe Money do
  context '#demongoize' do
    it "doesn't use symbolize_keys on BSON::Document" do
      doc1 = BSON::Document.new(cents: 1234, currency_iso: 'USD')
      doc2 = BSON::Document.new('cents' => 1234, 'currency_iso' => 'USD')

      expect(doc1).not_to receive(:symbolize_keys)
      expect(doc2).not_to receive(:symbolize_keys)

      expect(described_class.demongoize(doc1)).to eq(Money.new(1234, 'USD'))
      expect(described_class.demongoize(doc2)).to eq(Money.new(1234, 'USD'))
    end
  end

  context '#mongoize' do
    it "doesn't fail with BSON::Document on newer versions of bson gem" do
      doc1 = BSON::Document.new(cents: 1234, currency_iso: 'USD')
      doc2 = BSON::Document.new('cents' => 1234, 'currency_iso' => 'USD')

      allow(doc1).to receive(:symbolize_keys!).and_raise(
        ArgumentError, "symbolize_keys! is not supported on BSON::Document instances. Please convert the document to hash first (using #to_h), then call #symbolize_keys! on the Hash instance"
      )

      allow(doc2).to receive(:symbolize_keys!).and_raise(
        ArgumentError, "symbolize_keys! is not supported on BSON::Document instances. Please convert the document to hash first (using #to_h), then call #symbolize_keys! on the Hash instance"
      )

      expect(described_class.mongoize(doc1)).to eq({cents: 1234, currency_iso: 'USD'})
      expect(described_class.mongoize(doc2)).to eq({cents: 1234, currency_iso: 'USD'})
    end
  end
end
