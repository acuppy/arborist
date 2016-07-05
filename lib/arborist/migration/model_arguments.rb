class Arborist::Migration::ModelArguments
  DEFAULT_METHOD_NAME = :model

  attr_reader :ref_model, :method_name

  def initialize args
    options = args.extract_options!

    @ref_model   = args.first
    @method_name = options.fetch :as, DEFAULT_METHOD_NAME
  end
end
