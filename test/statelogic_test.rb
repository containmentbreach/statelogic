require 'test_helper'

#ActiveRecord::Base.logger = Logger.new(STDERR)

class OrderTest < ActiveSupport::TestCase
  include ActiveRecord::TestFixtures
  self.fixture_path = 'test/fixtures'

  fixtures :orders
  
  should_have_class_methods :unpaid,          :ready,          :redeemed,          :suspended
  should_have_class_methods :find_all_unpaid, :find_all_ready, :find_all_redeemed, :find_all_suspended

  should_have_instance_methods :unpaid?,     :ready?,     :redeemed?,     :suspended?
  should_have_instance_methods :was_unpaid?, :was_ready?, :was_redeemed?, :was_suspended?

  context 'Finders and scopes' do
    should 'return adequate shit' do
      for st in %w(unpaid ready redeemed suspended)
        assert_same_elements Order.find_all_by_state(st), Order.send(st)
        assert_same_elements Order.find_all_by_state(st), Order.send("find_all_#{st}")
      end
    end
  end
  
  should_validate_presence_of :state, :message => default_error_message(:inclusion)

  context 'A fresh order' do
    subject { Order.new }

    should_allow_values_for :state, 'unpaid'
    should_not_allow_values_for :state, 'ready', 'redeemed', 'suspended', 'screwed_up',
      :message => default_error_message(:inclusion)
    should_not_require_attributes :txref, :redeemed_at, :facility_id
  end

  context 'An unpaid order' do
    subject { orders(:unpaid) }

    should_allow_values_for :state, 'unpaid', 'ready', 'suspended'
    should_not_allow_values_for :state, 'redeemed', 'screwed_up',
      :message => default_error_message(:inclusion)
    should_not_require_attributes :txref, :redeemed_at, :facility_id
  end

  context 'A ready order' do
    subject { orders(:ready) }

    should_allow_values_for :state, 'ready', 'redeemed', 'suspended'
    should_not_allow_values_for :state, 'unpaid', 'screwed_up',
      :message => default_error_message(:inclusion)
    should_validate_presence_of :txref
    should_not_require_attributes :redeemed_at, :facility_id
  end

  context 'A redeemed order' do
    subject { orders(:redeemed) }

    should_allow_values_for :state, 'redeemed', 'suspended'
    should_not_allow_values_for :state, 'unpaid', 'ready', 'screwed_up',
      :message => default_error_message(:inclusion)
    should_validate_presence_of :txref, :redeemed_at, :facility_id
  end

  context 'A suspended order' do
    subject { orders(:suspended) }

    should_allow_values_for :state, 'suspended', 'redeemed', 'ready', 'unpaid'
    should_not_allow_values_for :state, 'screwed_up', :message => default_error_message(:inclusion)
    should_allow_values_for :txref, 'REF12345'
    should_not_allow_values_for :txref, '12345'
    should_not_require_attributes :txref, :redeemed_at, :facility_id
  end
end

