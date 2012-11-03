module ActiveMapper
	module Resource
		module PersistentStates
			class Persisted < PersistenceState
				def set(subject, value)
				  state = resource.send( :persistent_state=, Modified.new(resource))
					state.set(subject, value)
					state
				end

				def delete
					Deleted.new(resource)
				end

				def commit(options={ })
					repository.update(collection_for_self, options)
					set_resource
				end


				def set_resource
					set_child_keys
					set_repository
					Persisted.new(resource)
				end

				def rollback
					self
				end

			end
		end
	end
end

