require 'spec_helper'
require 'arborist/configuration'

module Arborist
  RSpec.describe Configuration do
    context 'when setting a value' do
      subject(:config) { described_class.new }

      specify do
        config.foo = :bar
        expect(config.foo).to eq :bar
      end
    end

    context 'when setting initial props' do
      subject(:config) { described_class.new foo: :bar }
      specify { expect(config.foo).to eq :bar }
    end
  end
end
