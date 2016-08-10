class Arborist::Migration::ModelArguments
  attr_reader :model_ref, :method_name

  def initialize args
    options = args.extract_options!

    @model_ref   = args.first || model_from_options(options)
    @method_name = options.fetch :as, config.default_method_name
  end

  private

  RESERVED_OPTIONS = %i( as )

  def model_from_options options
    options
      .select { |k, _| ! RESERVED_OPTIONS.include? k }
      .values
      .first
  end

  def config
    Arborist.config.migration
  end
end
