require 'active_record'
require 'arborist/version'
require 'arborist/configuration'

module Arborist
  class << self
    def config ns = nil
      @config     ||= Configuration.new
      @config[ns] ||= Configuration.new if ns

      if block_given?
        yield ns ? @config[ns] : @config
      end

      @config
    end
  end
end
