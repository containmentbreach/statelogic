ActiveRecord::Schema.define do
  create_table 'orders', :force => true do |t|
    t.column 'state',  :text
  end
end
