module ActiveMapper
	module Resource
		module PersistentStates
			class Locked < PersistenceState

				def get(subject, value)
					raise LockedResourceError, "The resource  is locked!. U can't access locked resource "
				end

				def set(subject, value)
					raise LockedResourceError, "The resource  is locked!. U can't access locked resource "
				end

				def delete
					raise LockedResourceError, "The resource  is locked!. U can't access locked resource "
				end


			end
		end
	end
end

class LockedResourceError < StandardError

end
