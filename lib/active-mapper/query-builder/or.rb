module ActiveMapper
	module QueryBuilder
		class Or < Condition

			attr_reader :left, :right

			def initialize(left, right)
				@left = @right = []
				@left = [left].flatten unless  left.blank?
				if right.kind_of?(Or)
					@left  += right.left
					@right += right.right
				else
					@right = [right].flatten
				end
			end


			def blank?
				!(left.any? && right.any?)
			end


			def merge(condition)
				if condition.and?
					Or.new(self.left, self.right + condition.children)
				else
					Or.new(self.left + condition.left, self.right + condition.right)
				end
			end


			# do the match of the left and right side
			# @return [Boolean]
			def match?(attributes={ })
				left.map do |el|
					break false unless el.respond_to?(:match?)
					el.match?(attributes)
				end.all? || right.map do |el|
					break false unless el.respond_to?(:match?)
					el.match?(attributes)
				end.all?
			end


			def to_hash
				{
						:or => @left.map(&:to_hash) + @right.map(&:to_hash)
				}
			end


		end
	end
end
