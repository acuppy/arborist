# frozen_string_literal: true
require_relative 'configuration'

module Arborist
  config :migration do |c|
    c.fallback            = ModelReferenceError
    c.default_method_name = :model
    c.default_direction   = :up
    c.default_message     = 'Migrating data...'
    c.reset_column_information = true
  end

  class Migration < ActiveRecord::Migration
    require_relative 'migration/collection'
    require_relative 'migration/data'
    require_relative 'migration/schema'

    include Data
    include Schema

    class << self
      attr_accessor :collection

      def reset!
        self.collection = Collection.new
      end

      private

      def config
        Arborist.config.migration
      end
    end

    def exec_migration(conn, dir)
      super conn, dir
      collection[dir].each do |m|
        m.report { instance_eval(&m.routine) }
      end
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
