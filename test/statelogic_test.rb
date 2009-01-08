require 'test_helper'

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
      validates_presence_of :txref, :redeemed_at, :facility_id
    end
    state 'suspended' do
      transitions_to 'unpaid', 'ready', 'redeemed'
      validate do |order|
        order.errors.add(:txref, :invalid) if order.txref && order.txref !~ /\AREF/
      end
    end
  end
end

class OrderTest < ActiveSupport::TestCase
  fixtures :orders

  should_require_attributes :state, :message => default_error_message(:inclusion)

  context 'A fresh order' do
    setup do
      @order = Order.new
    end

    should_allow_values_for :state, 'unpaid'
    should_not_allow_values_for :state, 'ready', 'redeemed', 'suspended', 'screwed_up',
      :message => default_error_message(:inclusion)
    should_not_require_attributes :txref, :redeemed_at, :facility_id
  end

  context 'An unpaid order' do
    setup do
      @order = orders(:unpaid)
    end

    should_allow_values_for :state, 'unpaid', 'ready', 'suspended'
    should_not_allow_values_for :state, 'redeemed', 'screwed_up',
      :message => default_error_message(:inclusion)
    should_not_require_attributes :txref, :redeemed_at, :facility_id
  end

  context 'A ready order' do
    setup do
      @order = orders(:ready)
    end

    should_allow_values_for :state, 'ready', 'redeemed', 'suspended'
    should_not_allow_values_for :state, 'unpaid', 'screwed_up',
      :message => default_error_message(:inclusion)
    should_require_attributes :txref
    should_not_require_attributes :redeemed_at, :facility_id
  end

  context 'A redeemed order' do
    setup do
      @order = orders(:redeemed)
    end

    should_allow_values_for :state, 'redeemed', 'suspended'
    should_not_allow_values_for :state, 'unpaid', 'ready', 'screwed_up',
      :message => default_error_message(:inclusion)
    should_require_attributes :txref, :redeemed_at, :facility_id
  end

  context 'A suspended order' do
    setup do
      @order = orders(:suspended)
    end

    should_allow_values_for :state, 'suspended', 'redeemed', 'ready', 'unpaid'
    should_not_allow_values_for :state, 'screwed_up', :message => default_error_message(:inclusion)
    should_allow_values_for :txref, 'REF12345'
    should_not_allow_values_for :txref, '12345'
    should_not_require_attributes :txref, :redeemed_at, :facility_id
  end
end
