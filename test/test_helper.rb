require 'rubygems'
require 'test/unit'
require 'active_support'
require 'active_support/test_case'
require 'active_record'
require 'shoulda/active_record'
require 'active_record/fixtures'
require 'statelogic/activerecord'

require 'shoulda_macros/statelogic'

#ActiveRecord::TestFixtures.fixture_path = 'test/fixtures'

ActiveRecord::Base.configurations = {
  'test' => {:adapter => 'sqlite3', :dbfile => ':memory:'}
}
ActiveRecord::Base.establish_connection(:test)

load 'schema.rb'
