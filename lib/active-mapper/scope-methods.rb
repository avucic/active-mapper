module ActiveMapper
	# ==  Scoped methods
	#
	# Responsible for building  interface  for the included/extended object
	#
	# Every method will raise NotImplementedError. So it needs to be overwritten with related logic from the host Class/Module
	#
	# Defined methods:
	#
	# * +where+
	# * +select+
	#	* +group+
	#	* +order+
	#	* +reorder+
	#	* +reverse_order+
	#	* +limit+
	#	* +offset+
	#	* +joins+
	#	* +includes+
	#	* +lock+
	#	* +readonly+
	#	* +from+
	#	* +having+
	#	* +first+
	#	* +last+
	module ScopeMethods

		METHODS =[
				:where,
				:select,
				:group,
				:order,
				:reorder,
				:reverse_order,
				:limit,
				:offset,
				:joins,
				:includes,
				:lock,
				:readonly,
				:from,
				:having,
				:first,
				:last
		].freeze

		METHODS.each do |method|
			define_method(method) do |*args, &block|
				message = if respond_to?(:superclass)
					          "Instance method :#{method} of the class #{self.class}##{method}  is  not  implemented"
					        else
						        "Class method #{self.class}##{method}  is  not  implemented"
					        end
				raise NotImplementedError.new message
			end unless method_defined?(method)
		end

	end
end


