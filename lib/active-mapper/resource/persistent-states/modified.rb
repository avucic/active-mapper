module ActiveMapper
	module Resource
		module PersistentStates
			class Modified < PersistenceState


				def set(subject, value)
					track(subject, value)
					super
					#original_attributes.empty? ? Persisted.new(resource) : self
					self
				end

				def delete
					reset_resource
					Deleted.new(resource)
				end

				def commit(options={ })
					repository.update(collection_for_self, resource.dirty_attributes, options)
					update_resource
				end


				def rollback
					reset_resource
					Persisted.new(resource)
				end

				def update_resource
					set_repository
					set_child_keys
					Persisted.new(resource)
				end


				private


				def track(subject, value)
					if original_attributes.key?(subject)
						# stop tracking if the new value is the same as the original
						if original_attributes[subject].eql?(value)
							original_attributes.delete(subject)
						end
					elsif !value.eql?(original = get(subject))
						# track the original value
						original_attributes[subject] = original
					end
				end

				def reset_resource
					reset_resource_key
					reset_resource_relationships
					reset_resource_properties
				end


				def reset_resource_properties
					# delete every original attribute after resetting the resource
					original_attributes.delete_if do |property, value|
						property.set!(resource, value)
						true
					end
				end

				def reset_resource_relationships
					relationships.each do |relationship|
						ivar = relationship.instance_variable_name
						resource.instance_eval { remove_instance_variable(ivar) if defined?(ivar) }
					end
				end

				def reset_resource_key
					resource.key #trigger to create that var. otherwise will throw error
					resource.instance_eval { remove_instance_variable(:@key) }
				end


				def original_attributes
					@original_attributes ||= { }
				end


			end
		end
	end
end
