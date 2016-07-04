require 'spec_helper'

describe Arborist do
  it 'has a version number' do
    expect(Arborist::VERSION).not_to be nil
  end

  describe '.config' do
    context 'without defining a namespace' do
      it 'creates a blank container at the root level' do
        expect(Arborist.config).to be_a Arborist::Configuration
      end
    end

    context 'when defining a namespaces' do
      it 'creates an empty container' do
        Arborist.module_eval { config :test }
        expect(Arborist.config.test).to be_a Arborist::Configuration
      end
    end

    context 'when passing a block' do
      it 'yields a configurable object' do
        Arborist.module_eval do
          config { |c| c.foo = :bar } # on the root
          config(:test) { |c| c.foo2 = :bar2 } # namespaced
        end

        expect(Arborist.config.foo).to eq :bar
        expect(Arborist.config.test.foo2).to eq :bar2
      end
    end
  end
end
