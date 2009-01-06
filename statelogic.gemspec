Gem::Specification.new do |s|
  s.specification_version = 2

  s.name = 'statelogic'
  s.version = '0.0.1'
  s.date = '2009-01-06'
  s.authors = ['Igor Gunko']
  s.email = 'tekmon@gmail.com'
  s.summary = 'Another state machine for ActiveRecord'
  s.description = <<-EOS
    Statelogic does kinda this and that... you know.
  EOS
  s.homepage = 'http://github.com/pipa/statelogic'
  s.rubygems_version = '1.3.1'

  s.require_paths = %w(lib)

  s.files = %w(
    README.rdoc MIT-LICENSE Rakefile
    lib/statelogic.rb
    lib/pipa-statelogic.rb
    lib/statelogic/activerecord.rb
    lib/statelogic/callbacks_ext.rb
    rails/init.rb
  )

  s.test_files = %w(
    test/statelogic_test.rb
    test/test_helper.rb
    test/schema.rb
    test/fixtures/orders.yml
    shoulda_macros/statelogic.rb
  )

  s.has_rdoc = true
  s.rdoc_options = %w(--line-numbers --inline-source --main README.rdoc)
  s.extra_rdoc_files = %w(README.rdoc MIT-LICENSE)

  s.add_dependency('activerecord', [">= 2.2.2"])
  s.add_development_dependency('thoughtbot-shoulda', ['>= 2.0.6'])
end
