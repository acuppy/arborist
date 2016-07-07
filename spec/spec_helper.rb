$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'pry-byebug'
require 'arborist'

RSpec.configure do |c|
  c.after(:all) { teardown_db }
end

ActiveRecord::Base.establish_connection(
  adapter: "sqlite3",
  database: ":memory:"
)

def define_schema(verbose = false, &schema)
  ActiveRecord::Schema.verbose = verbose
  ActiveRecord::Schema.define version: 1, &schema
end

def teardown_db
  conn = ActiveRecord::Base.connection
  conn.tables.each { |t| conn.drop_table t }
end

class TestModel < ActiveRecord::Base
  self.table_name = :test
end

class TestMigration < Arborist::Migration
  model :TestModel
  
  data do
    model.find_each do |tm|
      tm.fullname = 'abc'
      tm.save!
    end
  end

  def change
    add_column :test, :fullname, :string
  end
end

class SecondMigration < Arborist::Migration
  model :TestModel
  data { :noop }

  def change
    rename_column :test, :fullname, :full_name
  end
end
