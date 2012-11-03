module ActiveMapper
	module Associations
		class BelongsTo < OneToOne

			alias :inverse_model :target_model
			alias :inverse_repository_name :target_repository_name

			def get(source, query = nil)
				assoc = get!(source)
				assoc.read if assoc
			end


			def set(source, target_or_assoc)
				target = association?(target_or_assoc) ? target_or_assoc.child : target_or_assoc
				raise ArgumentError, "U can't associate #{target.inspect}  because the object is not the instance of the " +
						"#{target_model}" unless accept_resource?(target)
				source.send(:persistent_state).set(source_key,target_key.get(target)) if target
				#source_key.set(source, target_key.get(target)) if target
				set!(source, AssociationProxy.new(self, source, target))
				if inverse? # && target
					if inverse.kind_of?(HasMany)
						inverse.get(target).send(:replace, source)
					else
						inverse.set!(target, AssociationProxy.new(inverse, source, target))
					end
				end
			end

			def delete(source)
				target = nil
				assoc  = get!(source)
				target = assoc.parent if assoc
				if inverse? # && target
					if inverse.kind_of?(HasMany)
						inverse.get!(target).send(:remove, source)
					else
						inverse.set!(target, nil)
					end
				end
				source_key.set(source, nil)
				set!(source, nil)
			end

			private

			def accept_resource?(resource)
				return true if resource.nil? || resource.kind_of?(target_model)
				false
			end


		end
	end
end

