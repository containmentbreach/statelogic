class Test::Unit::TestCase
  def self.should_not_require_attributes(*attributes)
    get_options!(attributes)
    klass = model_class

    attributes.each do |attribute|
      should "not require #{attribute} to be set" do
        assert_good_value(klass, attribute, nil)
      end
    end
  end
end