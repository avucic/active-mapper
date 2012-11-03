module ActiveMapper
	module Associations
		class HasOne < OneToOne

			alias :inverse_model :source_model
			alias :inverse_repository_name :source_repository_name

			def get(target, query = nil)
				assoc = get!(target)
				get!(target).read if assoc
			end


			def set(target, source_or_assoc)
				source = association?(source_or_assoc) ? source_or_assoc.child : source_or_assoc
				raise ArgumentError, "U can't associate #{source.inspect}   because the object is not the instance of the " +
						"#{source_model}" unless accept_resource?(source)
				set!(target, AssociationProxy.new(self, source, target))
				if source
					inverse.set!(source, AssociationProxy.new(inverse, source, target))
					#	inverse.source_key.set(source, target_key.get(target))
					source.send(:persistent_state).set(inverse.source_key, target_key.get(target))
				end
			end

			def delete(target)
				source = nil
				assoc  = get!(target)
				source = assoc.read if assoc
				set!(target, nil)
				if inverse? && source
					inverse.set!(source, nil)
					source.send(:persistent_state).set(inverse.source_key, nil)
					case options[:dependent]
						when :destroy
							source.destroy
						when :delete
							source.delete
						when :nullify
							source.save
						else
							source.destroy
					end
				end
			end


			def accept_resource?(resource)
				return true if resource.nil? || resource.kind_of?(source_model)
				false
			end

		end
	end
end
