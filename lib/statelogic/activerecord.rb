require 'statelogic/callbacks_ext' unless ([ActiveRecord::VERSION::MAJOR, ActiveRecord::VERSION::MINOR] <=> [2, 3]) >= 0

module Statelogic
  module ActiveRecord
    def self.included(other)
      other.extend(ClassMethods)
    end

    module ClassMethods
      DEFAULT_OPTIONS = {:attribute => :state}.freeze

      class StateScopeHelper
        MACROS_PATTERN = /\Avalidates_/.freeze

        def initialize(cl, state, config)
          @class, @state, @config = cl, state, config
        end

        def validates_transition_to(*states)
          attr = @config[:attribute]
          options = states.extract_options!.update(
            :in => states,
            :if => [:"#{attr}_changed?", :"was_#{@state}?"]
          )
          @class.validates_inclusion_of(attr, options)
        end

        alias transitions_to validates_transition_to

        def method_missing(method, *args, &block)
          if method.to_s =~ MACROS_PATTERN || @class.respond_to?("#{method}_callback_chain")
            options = args.last
            args.push(options = {}) unless options.is_a?(Hash)
            options[:if] = Array(options[:if]).unshift(:"#{@state}?")
            @class.send(method, *args, &block)
          else
            super
          end
        end
      end

      class ConfigHelper
        def initialize(cl, config)
          @class, @config = cl, config
        end

        def initial_state(name, options = {}, &block)
          state(name, options.update(:initial => true), &block)
        end
        
        alias initial initial_state

        def state(name, options = {}, &block)
          attr = @config[:attribute]
          attr_was = :"#{attr}_was"
          @class.class_eval do
            define_method("#{name}?") { send(attr) == name }
            define_method("was_#{name}?") { send(attr_was) == name }
          end

          StateScopeHelper.new(@class, name, @config).instance_eval(&block) if block_given?

          @config[:states] << name
          @config[:initial] << name if options[:initial]
        end
      end

      def statelogic(options = {}, &block)
        options = DEFAULT_OPTIONS.merge(options)
        attr = options[:attribute] = options[:attribute].to_sym

        options[:states], options[:initial] = [], Array(options[:initial])

        ConfigHelper.new(self, options).instance_eval(&block)

        initial = [options[:initial], options[:states]].find {|x| !x.blank? }
        validates_inclusion_of attr, :in => initial, :on => :create if initial

        const = attr.to_s.pluralize.upcase
        const_set(const, options[:states].freeze.each(&:freeze)) unless const_defined?(const)
      end
    end
  end
end

# :stopdoc:
class ActiveRecord::Base
  include Statelogic::ActiveRecord
end
