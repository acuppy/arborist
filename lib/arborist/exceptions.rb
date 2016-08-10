module Arborist
  class ModelReferenceError < NameError
    def initialize model_ref
      super "#{model_ref} is not available"
    end

    def model
      raise self
    end
  end

  class UnknownSchemaMethod < ArgumentError
    def initialize method_name
      super %Q{Unknown schema migration method: #{method_name}.
        Use :up, :down or :change}
    end
  end

  class InheritanceError < StandardError
    def initialize method_name
      super %Q{ Method not available in ActiveRecord::Migration. Inherit from
        Arborist::Migration to use #{method_name}}
    end
  end
end
