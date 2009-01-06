ActiveRecord::Schema.define do
  create_table 'orders', :force => true do |t|
    t.column 'state', :text
    t.column 'redeemed_at', :datetime
    t.column 'txref', :string
    t.references :facility
  end
end
