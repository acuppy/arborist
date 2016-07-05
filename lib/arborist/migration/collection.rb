require 'delegate'

class Arborist::Migration::Collection
  extend Forwardable
  def_delegators :@collection, :[], :fetch

  def initialize
    @collection = { up:[], down:[] }
  end
end
