require 'ostruct'

module Arborist
  class Configuration < OpenStruct
    def initialize props={}
      super
      yield self if block_given?
    end
  end
end
