class Arborist::Migration::DataMigration
  attr_reader :direction, :routine

  def initialize *args, &block
    options = args.extract_options!

    @direction = args.first || config.default_direction
    @routine   = options[:use].new rescue block
  end

  alias :to_proc :routine

  private

  def config
    Arborist.config.migration
  end
end
