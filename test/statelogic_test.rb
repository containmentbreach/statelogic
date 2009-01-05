require 'test_helper'

ActiveRecord::Base.establish_connection(:adapter => 'sqlite3', :dbfile => ':memory:')

class StatelogicTest < ActiveSupport::TestCase
  #fixtures :orders

  class Order < ActiveRecord::Base
    statelogic do
      initial_state 'unpaid' do
        transitions_to 'ready', 'suspended'
      end
      state 'ready' do
        transitions_to 'redeemed', 'suspended'
        validates_presence_of :txref
      end
      state 'redeemed' do
        transitions_to 'suspended'
        validates_presence_of :redeemed_at, :facility_id
        validates_presence_of :txref
      end
    end
  end

  def setup
    load 'schema.rb'
    @record = Order.new
  end
  
  test 'the_truth' do
#    @record.state = 'screwed_up'
#    assert !@record.ready?
#    assert !@record.valid?
#    @record.state = 'ready'
#    assert !@record.valid?
    @record.state = 'unpaida'
    #assert @record.unpaid?
    assert @record.valid?, @record.errors.full_messages * ' '
  end
end
