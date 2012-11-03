module ActiveMapper
	module Resource
		module PersistentStates
			class Readonly < PersistenceState


				def set(subject, value)
					raise ReadonlyResourceError, "The resource #{resource}   is Readonly and can't be modified or destroyed"
				end

				def delete
					raise ReadonlyResourceError, "The resource #{resource}  is Readonly and can't be modified or destroyed"
				end

				def commit(options={})
					self
				end

				def rollback
					self
				end

			end
		end
	end
end

class ReadonlyResourceError < StandardError

end
