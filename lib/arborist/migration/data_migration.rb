class Arborist::Migration::DataMigration
  attr_reader :direction, :routine

  def initialize *args, &block
    @options = args.extract_options!

    @direction = args.first || config.default_direction
    @routine   = @options[:use].new rescue block
  end

  def report &block
    puts "~> #{config.default_message} #{options[:say]}"
    time = Benchmark.measure(&block)
    puts "~> Completed. Time elapsed: %.4fs" % time.real
  end

  private

  attr_reader :options

  def config
    Arborist.config.migration
  end
end
