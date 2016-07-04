require 'ostruct'

module Arborist
  def self.config ns = nil
    @config     ||= Configuration.new
    @config[ns] ||= Configuration.new if ns

    if block_given?
      yield ns ? @config[ns] : @config
    end

    @config
  end

  class Configuration < OpenStruct
    def initialize props={}
      super
      yield self if block_given?
    end
  end
end
