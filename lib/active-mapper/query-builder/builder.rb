module ActiveMapper
	module QueryBuilder
		class Builder

			def self.build(&block)
				return Condition.new unless block_given?
				if block.arity > 0
					yield self.new
				else
					self.new.instance_eval(&block)
				end
			end

			private


			def method_missing(method_id, *args)
				super if method_id == :to_ary
				Expression.new method_id
			end
		end
	end
end
