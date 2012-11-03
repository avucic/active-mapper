module ActiveMapper
	module Resource
		module PersistentStates
			class NotPersisted < PersistenceState


				def delete
					Deleted.new(resource)
				end


				def commit(options={ })
					response = repository.create(resource, options).dup rescue nil
					set_attributes(response)
					if resource.key.get(resource).nil?
						self
					else
						set_child_keys
						set_repository
						Persisted.new(resource)
					end
				end


				private


				def set_attributes(response)
					(response || { }).each do |key, value|
						resource.properties[key.to_sym].set(resource, value)
					end
				end

				def track(subject)
					original_attributes[subject] = nil
				end

				def original_attributes
					@original_attributes ||= { }
				end


			end
		end
	end
end
