require 'spec_helper'
require 'arborist/migration/model_arguments'

describe Arborist::Migration::ModelArguments do
  subject(:model_args) { described_class.new args }

  context 'when default' do
    let(:args) { [:TestModel] }

    it { expect(model_args.model_ref).to eq :TestModel }
    it { expect(model_args.method_name).to eq :model }
  end

  context 'when declaring a method name' do
    let(:args) { [:TestModel, { as: :test_method }] }

    it { expect(model_args.model_ref).to eq :TestModel }
    it { expect(model_args.method_name).to eq :test_method }
  end

  context 'when declaring a method name' do
    let(:args) { [:TestModel, { as: :test_method }] }

    it { expect(model_args.model_ref).to eq :TestModel }
    it { expect(model_args.method_name).to eq :test_method }
  end

  context 'when a fallback is defined' do
    let(:args) { [{ :Unknown => :TestModel }] }

    it { expect(model_args.model_ref).to eq :TestModel }
  end
end
