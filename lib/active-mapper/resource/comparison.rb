module ActiveMapper
	module Resource
		module Comparison
			def ==(other)
				return false unless other.kind_of?(Resource) && model.base_model.equal?(other.model.base_model)
				return false unless repository == other.repository && key == other.key
				if saved? && other.saved?
					dirty_attributes == other.dirty_attributes
				else
					properties.all? do |property|
						__send__(property.name) == other.__send__(property.name)
					end
				end
			end


			def -(other)
				raise NotImplementedError, "Comparation of two resource objects currently not supported"
			end


			def +(other)
				raise NotImplementedError, "Comparation of two resource objects currently not supported"
			end

			def <=>(other)
				raise NotImplementedError, "Comparation of two resource objects currently not supported"
			end



			def eql?(other)
				return true if equal?(other)
				return false unless instance_of?(other.class)
				return false unless repository == other.repository && key == other.key
				if saved? && other.saved?
					dirty_attributes == other.dirty_attributes
				else
					properties.all? do |property|
						__send__(property.name) == other.__send__(property.name)
					end
				end
			end
		end
	end
end
