module ActiveMapper
	module Resource
		module PersistentStates
			class Deleted < PersistenceState

				def get(subject, value)
					raise DeletedError, 'Deleted resource cannot be modified'
				end

				def set(subject, value)
					raise DeletedError, 'Deleted resource cannot be modified'
				end

				def delete
					self
				end

				def commit(options={ })
					repository.delete(collection_for_self, options)
					delete_resource
				end


				def delete_resource
					resource.model.scoped.send :remove, resource
					relationships.each do |relationship|
						relationship.delete(resource)
					end
					Immutable.new(resource)
				end

			end
		end
	end
end

class DeletedError < StandardError

end
