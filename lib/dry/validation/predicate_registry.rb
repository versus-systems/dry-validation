module Dry
  module Validation
    class PredicateRegistry
      attr_reader :predicates
      attr_reader :external

      class Bound < PredicateRegistry
        attr_reader :schema

        def initialize(*args)
          super(*args[0..1])
          @schema = args.last
          freeze
        end
      end

      class Unbound < PredicateRegistry
        def bind(schema)
          bound_predicates = predicates.each_with_object({}) do |(n, p), res|
            res[n] = p.bind(schema)
          end
          Bound.new(external, bound_predicates, schema)
        end

        def update(other)
          unbound_predicates = other.each_with_object({}) { |(n, p), res|
            res[n] = Logic::Predicate.new(n, fn: p)
          }
          predicates.update(unbound_predicates)
          self
        end
      end

      def self.[](klass, predicates)
        Unbound.new(predicates).tap do |registry|
          klass.class_eval do
            def self.method_added(name)
              super
              if name.to_s.end_with?('?')
                registry.update(name => instance_method(name))
              end
            end
          end
        end
      end

      def initialize(external, predicates = {})
        @external = external
        @predicates = predicates
      end

      def new(klass)
        new_predicates = predicates
          .keys
          .each_with_object({}) { |key, res| res[key] = klass.instance_method(key) }

        self.class.new(external).update(new_predicates)
      end

      def [](name)
        predicates.fetch(name) do
          if external.key?(name)
            external[name]
          else
            raise_unknown_predicate_error(name)
          end
        end
      end

      def key?(name)
        predicates.key?(name) || external.key?(name)
      end

      def ensure_valid_predicate(name, args_or_arity, schema = nil)
        return if schema && schema.instance_methods.include?(name)

        if name == :key?
          raise InvalidSchemaError, "#{name} is a reserved predicate name"
        end

        if key?(name)
          arity = self[name].arity

          case args_or_arity
          when Array
            raise_invalid_arity_error(name) if ![0, args_or_arity.size + 1].include?(arity)
          when Integer
            raise_invalid_arity_error(name) if args_or_arity != arity
          end
        else
          raise_unknown_predicate_error(name)
        end
      end

      private

      def raise_unknown_predicate_error(name)
        raise ArgumentError, "+#{name}+ is not a valid predicate name"
      end

      def raise_invalid_arity_error(name)
        raise ArgumentError, "#{name} predicate arity is invalid"
      end
    end
  end
end
