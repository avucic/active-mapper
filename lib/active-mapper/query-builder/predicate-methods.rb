module ActiveMapper
	module QueryBuilder
		module PredicateMethods
			# @return [Or]
			def |(other)
				Or.new(self, other)
			end

			# @return [And]
			def &(other)
				And.new(self, other)
			end

		end
	end
end
