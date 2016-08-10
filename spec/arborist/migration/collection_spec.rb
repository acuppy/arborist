# frozen_string_literal: true
require 'spec_helper'
require 'arborist/migration/collection'

describe Arborist::Migration::Collection do
  subject(:collection) { described_class.new }

  it { expect(collection.fetch(:up)).to eq [] }
  it { expect(collection.fetch(:down)).to eq [] }
end
