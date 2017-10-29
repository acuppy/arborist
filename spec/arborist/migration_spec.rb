# frozen_string_literal: true
require 'spec_helper'

describe Arborist::Migration do
  describe 'public interface' do
    %i(collection model_ref data model reset!).each do |class_method|
      it { expect(described_class).to respond_to class_method }
    end
  end

  describe 'configuration' do
    it 'sets up a migration container' do
      expect(Arborist.config.migration).to be_a Arborist::Configuration
    end
  end

  describe '.data' do
    after { Arborist::Migration.reset! }

    context 'without specifying a direction' do
      it 'adds a migration routine to the :up collection' do
        Arborist::Migration.data { :noop }
        expect(Arborist::Migration.collection[:up].length).to eq 1
      end
    end

    context 'when specifying a direction' do
      it 'adds a migration routine to the appropriate collection' do
        Arborist::Migration.data(:down) { :noop }

        expect(Arborist::Migration.collection[:up].length).to eq 0
        expect(Arborist::Migration.collection[:down].length).to eq 1
      end
    end

    context 'when providing a data class' do
      it 'delegates to the class' do
        Arborist::Migration.data use: Proc

        expect(Arborist::Migration.collection[:up].length).to eq 1
      end
    end
  end

  describe '.schema' do
    after { Arborist::Migration.reset! }

    context 'when a migration method is passed in' do
      before do
        TestMigration.class_eval do
          schema(:up) {}
        end
      end

      it { expect(TestMigration.new).to respond_to :up }
    end

    context 'when a migration method being passed in does not exist' do
      specify do
        expect do
          TestMigration.class_eval { schema(:foo) {} }
        end.to raise_error Arborist::UnknownSchemaMethod
      end
    end
  end

  describe '.model' do
    context 'when the referenced model exists' do
      before { Arborist::Migration.model :TestModel }

      it 'defines a model reference via #model' do
        expect(Arborist::Migration.new.model).to eq TestModel
      end

      it 'resets the column information' do
        expect(Arborist::Migration.new.model).to eq TestModel
      end
    end

    context 'when the model being referenced does not exist' do
      specify do
        expect { Arborist::Migration.model :UnknownModel }
          .to raise_error Arborist::ModelReferenceError
      end
    end
  end

  describe '.reset!' do
    it 'clears out the collection of migrations' do
      Arborist::Migration.data { :noop }
      expect(Arborist::Migration.collection[:up].length).to eq 1
      Arborist::Migration.reset!
      expect(Arborist::Migration.collection[:up].length).to eq 0
    end
  end
end

describe TestMigration do
  before :all do
    define_schema do
      create_table(:test) { |t| t.timestamps null: false }
    end

    TestModel.create!
  end

  describe 'migrating up' do
    it 'fills in the missing value' do
      expect(TestModel.first).to_not respond_to :fullname

      ActiveRecord::Migration.run TestMigration
      expect(TestModel.first.fullname).to be_present

      ActiveRecord::Migration.run SecondMigration
      expect(TestModel.first.reload.full_name).to be_present
    end
  end
end
