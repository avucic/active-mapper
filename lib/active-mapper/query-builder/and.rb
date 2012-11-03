module ActiveMapper
	module QueryBuilder
		#todo clean this
		class And < Condition
			attr_reader :children

			def initialize(*args)
				@children =[]
				args.compact.each do |arg|
					@children << arg if arg.kind_of?(Predicate)
					@children += [arg].flatten.compact unless arg.kind_of?(And)
					merge_condition(arg) if arg.kind_of?(And)
				end
				@children = (@children).flatten.compact.uniq
			end


			def blank?
				!children.any?
			end

			# do the match of the all children
			# @return [Boolean]
			def match?(attributes={ })
				children.map do |el|
					break false unless el.respond_to?(:match?)
					el.match?(attributes)
				end.all?
			end


			def to_hash
				{
						:and => @children.map(&:to_hash)
				}
			end


			def merge(condition)
				if condition.or?
					Or.new(condition.left + [self], condition.right)
				else
					And.new(children + condition.children)
				end
			end

			private


			def merge_condition(condition)
				arr = [condition.children].flatten rescue []
				@children = (@children + arr).flatten.compact.uniq
			end

		end
	end
end
