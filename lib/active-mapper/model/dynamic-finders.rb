module ActiveMapper
	module Model
		module DynamicFinders
			extend ActiveSupport::Concern
			module ClassMethods
				def method_missing(method_sym, *arguments, &block)
					# the first argument is a Symbol, so you need to_s it if you want to pattern match
					if method_sym.to_s =~ /^find_by_(.*)$/
						#find($1.to_sym => arguments.first)
						where($1 => arguments.first).first
					else
						super
					end
				end

				def respond_to?(method_sym, include_private = false)
					if method_sym.to_s =~ /^find_by_(.*)$/
						true
					else
						super
					end
				end
			end
		end
	end
end
