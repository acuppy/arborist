require_relative 'configuration'

module Arborist
  config :migration do |c|
    c.fallback = ModelReferenceError
  end

  class Migration < ActiveRecord::Migration
    require_relative 'migration/collection'
    require_relative 'migration/model_arguments'

    class << self
      attr_accessor :collection
      attr_accessor :ref_model

      def data dir = :up, &migration
        self.collection ||= Collection.new
        self.collection[dir] << migration
      end

      def model *args
        model_args = ModelArguments.new args
        define_model_reference model_args.ref_model
        define_model_method model_args
      end

      def reset!
        self.collection = Collection.new
      end

      private

      def define_model_method model_args
        define_method model_args.method_name do
          @_ref ||= {}
          @_ref[model_args] ||= begin
            ref = self.class.ref_model.fetch model_args.ref_model
            ref.tap(&:reset_column_information)
          end
        end
      end

      def define_model_reference ref_model
        self.ref_model ||= {}
        self.ref_model[ref_model] ||= Object.const_get ref_model
      rescue NameError
        config.fallback.new(ref_model).model
      end

      def config
        Arborist.config.migration
      end
    end

    def exec_migration conn, dir
      super conn, dir
      collection[dir].each { |m| instance_eval(&m) }
    end

    private

    def collection
      self.class.collection
    end

    def config
      self.class.config
    end
  end
end
