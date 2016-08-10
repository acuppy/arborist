module Arborist::Migration::Data
  extend ActiveSupport::Concern

  require_relative 'data_migration'
  require_relative 'model_arguments'

  Collection     = Arborist::Migration::Collection
  DataMigration  = Arborist::Migration::DataMigration
  ModelArguments = Arborist::Migration::ModelArguments

  module ClassMethods
    attr_accessor :model_ref

    def data *args, &migration
      data_migration = DataMigration.new *args, &migration

      self.collection ||= Collection.new
      self.collection[data_migration.direction] << data_migration
    end

    def model *args
      model_args = ModelArguments.new args
      define_model_reference model_args.model_ref
      define_model_method model_args
    end

    private

    def define_model_method model_args
      define_method model_args.method_name do
        @_ref ||= {}
        @_ref[model_args] ||= begin
          ref = self.class.model_ref.fetch model_args.model_ref

          if Arborist.config.migration.reset_column_information
            ref.tap(&:reset_column_information)
          end
        end
      end
    end

    def define_model_reference model_ref
      self.model_ref ||= {}
      self.model_ref[model_ref] ||= Object.const_get model_ref
    rescue NameError
      config.fallback.new(model_ref).model
    end

    def config
      Arborist.config.migration
    end
  end
end
