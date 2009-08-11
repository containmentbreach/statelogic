require 'statelogic/callbacks_ext' unless ([ActiveRecord::VERSION::MAJOR, ActiveRecord::VERSION::MINOR] <=> [2, 3]) >= 0

module Statelogic
  module Util
    def self.debug(msg = nil, &block)
      ::ActiveRecord::Base.logger.debug(msg, &block) if ::ActiveRecord::Base.logger
    end

    def self.warn(msg = nil, &block)
      ::ActiveRecord::Base.logger.warn(msg, &block) if ::ActiveRecord::Base.logger
    end

    def self.defmethod(cls, name, meta = false, &block)
      c = meta ? cls.metaclass : cls
      unless c.method_defined?(name)
        c.send(:define_method, name, &block)
        Util.debug { "Statelogic created #{meta ? 'class' : 'instance'} method #{name} on #{cls.name}." }
      else
        warn { "Statelogic won't override #{meta ? 'class' : 'instance'} method #{name} already defined on #{cls.name}." }
        nil
      end
    end
  end
    
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
          name = name.to_s
          uname = name.underscore
          attr = @config[:attribute]
          attr_was = :"#{attr}_was"
          find_all_by_attr = "find_all_by_#{attr}"

          Util.defmethod(@class, "#{uname}?") { send(attr) == name }
          Util.defmethod(@class, "was_#{uname}?") { send(attr_was) == name }

          unless @class.respond_to?(name)
            @class.send(:named_scope, uname, :conditions => {attr.to_sym => name })
            Util.debug { "Statelogic has defined named scope #{uname} on #{@class.name}." }
          else
            Util.warn { "Statelogic won't override class method #{uname} already defined on #{@class.name}." }
          end

          Util.defmethod(@class, "find_all_#{uname}", true) {|*args| send(find_all_by_attr, name, *args) }

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

        initial = [options[:initial], options[:states]].find(&:present?)
        validates_inclusion_of attr, :in => initial, :on => :create if initial

        const = attr.to_s.pluralize.upcase
        const_set(const, options[:states].freeze.each(&:freeze)) unless const_defined?(const)
      end
    end
  end
end

ActiveRecord::Base.send :include, Statelogic::ActiveRecord

