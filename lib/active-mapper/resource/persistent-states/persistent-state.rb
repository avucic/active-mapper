module ActiveMapper
	module Resource
		module PersistentStates
			class PersistenceState

				attr_reader :resource

				def initialize(resource)
					@resource = resource
					@model    = resource.model
				end

				def get(subject, *args)
					subject.get(resource, *args)
				end

				def set(subject, value)
					subject.set(resource, value)
					self
				end

				def delete
					raise NotImplementedError, "#{self.class}#delete should be implemented"
				end

				def commit
					raise NotImplementedError, "#{self.class}#commit should be implemented"
				end

				def rollback
					raise NotImplementedError, "#{self.class}#rollback should be implemented"
				end

				private







				attr_reader :model

				def repository
					@repository ||= model.repository
				end


				def properties
					@properties ||= model.properties(repository.name)
				end

				def relationships
					@relationships ||= model.relationships(repository.name)
				end


				def set_child_keys
					relationships.each do |relationship|
						set_child_key(relationship)
					end
				end


				def set_repository
					resource.instance_variable_set(:@_repository, repository)
				end

				def set_child_key(relationship)
					set(relationship, get(relationship))
				end

				def collection_for_self
					resource.collection_for_self
				end






			end
		end
	end
end


