module ActiveMapper
	module QueryBuilder
		#todo clean this
		class Predicate
			include PredicateMethods

			attr_reader :attribute, :method_name, :value

			def initialize(attribute, method_name = :eq, value = :__undefined__)
				@attribute   = attribute
				@method_name = method_name
				@value       = value
			end


			# do the match of predicate by comparing values with defined comparator (method_name)
			# @return [Boolean]
			def match?(attr={ })
				return false unless (match_value = attr[@attribute])
				compare(match_value)
			end


			def to_hash
				{ :attribute => @attribute, :method_name => @method_name, :value => @value }
			end


			private


			#can be simplified  bu let keep this for reading
			def compare(match_value)
				begin
					case self.method_name
						when :eq, :==
							match_value == self.value
						when :not_eq, :'!='
							match_value != self.value
						when :in
							value.include?(match_value)
						when :not_in
							!value.include?(match_value)
						when :matches, :=~
							!!(match_value =~/#{Regexp.escape(value)}/)
						when :does_not_match
							!(match_value =~/#{Regexp.escape(value)}/)
						when :gt
							match_value > value
						when :gteq
							match_value >= value
						when :lt
							match_value < value
						when :lteq
							match_value <= value
						else
							match_value.send(method_name, value)
					end
				rescue => e
					false
				end
			end
		end
	end
end
