# frozen_string_literal: true
require 'ostruct'

module Arborist
  def self.config(ns = nil)
    @config     ||= Configuration.new
    @config[ns] ||= Configuration.new if ns

    yield ns ? @config[ns] : @config if block_given?

    @config
  end

  class Configuration < OpenStruct
    def initialize(props = {})
      super
      yield self if block_given?
    end
  end
end
