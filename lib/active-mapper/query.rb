require "active-mapper/query-builder/predicate-methods"
require "active-mapper/query-builder/condition"
require "active-mapper/query-builder/and"
require "active-mapper/query-builder/or"
require "active-mapper/query-builder/predicate"
require "active-mapper/query-builder/expression"
require "active-mapper/query-builder/builder"
require "active-mapper/scope-methods"

module ActiveMapper
	class Query
		include QueryBuilder


		attr_reader :expression
		attr_accessor :repository, :model, :options

		def initialize(options={ }, &block)
			@options = options.dup rescue { }
			@model      = @options.delete(:model)
			@repository = @options.delete(:repository)
			@expression = block_given? ? Builder.build(&block) : predicate_or_condition({ })
			@output     ={ }

		end


		def storage_name
			@storage_name ||= @model.storage_name if @model
		end


		##
		# Build where (And) condition
		#
		# @param [Hash] options
		#   Pass hash with arguments to build query
		#
		# Example:
		#
		#   where({:title=>'something'})
		#
		# Note:
		#  * If the block is passed, hash will be ignored
		#  * All operators for condition will be :eq, but you can build comparing conditions by joining +where+ and +or+ conditions
		#
		# Example:
		#   where({:title=>'something'}).or({:title=>'something else'})
		#
		# @param [Proc] block
		#   For building dynamic query
		#
		# Example:
		#   where{(name == 'something') | (name == 'something else')}
		#
		# Note:
		#  * You have to use brackets *()* to prioritize query blocks like in previous example
		#
		def where(options={ }, &block)
			if block_given?
				@expression= (@expression & Builder.build(&block))
			else
				@expression= (@expression & predicate_or_condition(options))
			end
			self
		end

		#similar to where, just add the *OR* condition to the query object
		#
		# @param [Hash] options
		# @param [Proc] block
		def or(options={ }, &block)
			if block_given?
				@expression= (@expression | Builder.build(&block))
			else
				@expression= (@expression | predicate_or_condition(options))
			end
			self
		end

		alias :and :where




		#
		# @param [Query, Hash] query
		# @return [Query]
		# === Example of hash params:
		#
		#   {:joins=>[:members]}
		#todo should be refactored
		def update(object)
			return self unless object
			raise ArgumentError.new "The object must be the instance of the Query." unless object.kind_of?(Query) || object.is_a?(Hash)
			# well it's not nice, but we don't want to expose something what isn't necessary
			if object.is_a?(Hash)
				object.each do |k, v|
					if  @output.key?(k)
						@output[k] = @output[k].is_a?(Array) ? ([v] + [@output[k]]).flatten.uniq : v
					else
						@output[k] = v
					end
				end
			else
				@expression = @expression.merge(object.expression)
				#merge or update values
				(object.instance_variable_get(:@output) || { }).tap { |o| self.update(o) }
				(object.instance_variable_get(:@options) || { }).tap { |o| self.update(o) }
			end
			self
		end


		##
		# Comparing the query logic with passed arguments
		# This is very useful to see  does some condition is satisfied
		#
		# @param [Hash] options
		#   Arguments to be compared against the query
		#
		# Example:
		#
		#   where{name == 'something'}.match?(:name=>'something')  #=> return  true
		#   where{name != 'something'}.match?(:name=>'something')  #=> return  false
		#
		def match?(*attributes)
			case
				when attributes.empty?
					false
				when !@expression.respond_to?(:match?)
					false
				else
					@expression.match?(attributes.last)
			end
		end

		def expression?
			!@expression.blank?
		end


		##
		# Return the query hash
		#
		# Example:
		#
		#   where{(name == 'something').to_hash #=>  {:and => [  { :attribute => :name, :method_name => :eq, :value => 'john' }  ]}
		#
		def to_hash
			@output.merge(!expression? ? { } : @expression.to_hash)
		end

		def to_json
			to_hash.to_json
		end

		private


		def predicate_or_condition(object)
			if object.is_a?(And) || object.is_a?(Or)
				object
			else
				And.new(build_predicates(object))
			end
		end

		def build_predicates(*args)
			arg = args.last
			return [] unless arg
			case
				when arg.is_a?(Predicate)
					[arg]
				when arg.is_a?(Hash)
					arg.inject([]) do |out, (key, value)|
						out << Predicate.new(key, :eq, value)
						out
					end
				else
					[]
			end
		end

		#create getter, setter and booleans for additional association methods
		ScopeMethods::METHODS.each do |meth|
			unless method_defined?(meth)
				define_method(meth) do |args=nil|
					if args
						@output.update({ meth => args })
						self
					else
						@output[meth]
					end
				end

				define_method("#{meth}?") do
					!!@output[meth]
					self
				end
			end
		end

	end
end


