class Arborist::Migration::ModelArguments
  attr_reader :ref_model, :method_name

  def initialize args
    options = args.extract_options!

    @ref_model   = args.first
    @method_name = options.fetch :as, config.default_method_name
  end

  private

  def config
    Arborist.config.migration
  end
end
