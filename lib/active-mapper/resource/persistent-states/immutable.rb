module ActiveMapper
	module Resource
		module PersistentStates
			class Immutable < PersistenceState
				def get(subject, value)
					raise ImmutableError, "Immutable resource can't be loaded"
				end

				def set(subject, value)
					raise ImmutableError, 'Immutable resource cannot be modified'
				end

				def delete
					raise ImmutableError, 'Immutable resource cannot be deleted'
				end

				def commit(*)
					self
				end

				def rollback
					self
				end

			end
		end
	end
end

class ImmutableError < StandardError

end
