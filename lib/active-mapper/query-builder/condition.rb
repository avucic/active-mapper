module ActiveMapper
	module QueryBuilder
		# This is the Base class for And and Or objects
		class Condition
			include PredicateMethods

			def or?
				self.kind_of?(Or)
			end

			def and?
				self.kind_of?(And)
			end

			def predicate?
				self.kind_of?(Predicate)
			end

			def condition?
				self.kind_of?(Condition)
			end

			def merge
				raise NotImplementedError.new "This method should be overridden by AND or OR condition. Something wrong..."
			end


		end
	end
end