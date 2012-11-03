module ActiveMapper
	module QueryBuilder

		# On this class will be defined all comparators methods and their aliases which are important for the dynamic method chain.
		# When the method is triggered, instance of this object will return new And condition object as the last thing.
		#
		#
		# == Aliases
		#
		# * "==" , :eq
		# * !=, ^ :not_eq
		# * "=~ " :matches
		# * '!~' :does_not_match
		# * > :gt
		# * >= :gteq
		# * < :lt
		# * <= :lteq
		class Expression

			PREDICATES = [
					:eq,
					:not_eq,
					:matches,
					:does_not_match,
					:lt,
					:lteq,
					:gt,
					:gteq,
					:in,
					:not_in,
			].freeze

			PREDICATE_ALIASES = {
					:matches        => [:like],
					:does_not_match => [:not_like],
					:lteq           => [:lte],
					:gteq           => [:gte]
			}.freeze


			PREDICATES.each do |method_name|
				define_method(method_name) do |value|
					And.new(Predicate.new(@symbol, method_name, value || :__undefined__))
				end
			end

			PREDICATE_ALIASES.each do |key, aliases|
				aliases.each do |al|
					send :alias_method, al, key
				end
			end


			alias :== :eq
			alias :'^' :not_eq
			alias :'!=' :not_eq if respond_to?(:'!=')
			alias :<< :not_in
			alias :=~ :matches
			alias :'!~' :does_not_match if respond_to?(:'!~')
			alias :> :gt
			alias :>= :gteq
			alias :< :lt
			alias :<= :lteq


			def initialize(symbol= nil)
				@symbol = symbol
			end

			def method_missing(method_id, *args)
				raise ArgumentError, "Currently key path is not supported. Please use something like: { name == 'something'} or { name.like 'something'}"
			end


		end
	end
end
