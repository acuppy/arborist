module Arborist
  class ModelReferenceError < NameError
    def initialize ref_model
      super "#{ref_model} is not available"
    end

    def model
      raise self
    end
  end
end
