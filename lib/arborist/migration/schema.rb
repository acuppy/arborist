# frozen_string_literal: true
module Arborist::Migration::Schema
  extend ActiveSupport::Concern

  module ClassMethods
    def schema(method = :change, &migration)
      if SCHEMA_MIGRATION_METHODS.include? method
        define_method method, &migration
      else
        raise Arborist::UnknownSchemaMethod, method
      end
    end

    private

    SCHEMA_MIGRATION_METHODS = %i(up down change).freeze
  end
end
