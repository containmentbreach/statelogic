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

