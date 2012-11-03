require "active-mapper/resource/persistent-states/persistent-state"
require "active-mapper/resource/persistent-states/deleted"
require "active-mapper/resource/persistent-states/readonly"
require "active-mapper/resource/persistent-states/locked"
require "active-mapper/resource/persistent-states/modified"
require "active-mapper/resource/persistent-states/persisted"
require "active-mapper/resource/persistent-states/not-persisted"
require "active-mapper/resource/persistent-states/immutable"


module ActiveMapper
	module Resource
		module PersistentStates
			extend ActiveSupport::Concern

			module ClassMethods
				protected


				def readonly
					define_method :persistent_state do
						@_persistent_state ||= Readonly.new(self)
					end
				end

				def locked
					define_method :persistent_state do
						@_persistent_state ||= Locked.new(self)
					end
				end


				def build_and_persist(resources)
					new_records = build(resources)
					resources.is_a?(Array) ? new_records.collect { |record|  send(:persist_resource, record) } :  send(:persist_resource, new_records)
				end

				def persist_resource(resource)
					if resource && resource.class == self && !resource.key.get(resource).nil?
						resource.send(:persistent_state=, Resource::PersistentStates::Persisted.new(resource))
						resource.send(:persistent_state=, resource.send(:persistent_state).set_resource)
						resource
					end
				end

			end


			def new?
				properties.key.get(self).nil? && not_persisted?
			end

			#for rails
			alias :new_record? :new?

			def not_persisted?
				persistent_state.kind_of?(NotPersisted)
			end


			def persisted?
				persistent_state.kind_of?(Persisted)
			end

			def not_deleted?
				!deleted?
			end

			alias :not_destroyed? :not_deleted?

			def deleted?
				persistent_state.kind_of?(Deleted) || immutable?
			end

			alias :destroyed? :deleted?

			def not_modified?
				!modified?
			end


			def modified?
				persistent_state.kind_of?(Modified)
			end

			def readonly?
				persistent_state.kind_of?(Readonly)
			end

			def locked?
				persistent_state.kind_of?(Locked)
			end

			def immutable?
				persistent_state.kind_of?(Immutable)
			end

			def not_saved?
				!saved?
			end

			def saved?
				persisted?
			end

			def dirty_attributes
				dirty_attributes = { }
				original_attributes.each_key do |property|
					dirty_attributes[property] = read_attribute(property)
				end
				dirty_attributes
			end


			def changes
				original_attributes.inject({ }) do |out, (k, v)|
					out[k] = [v, read_attribute(k)]
					out
				end
			end

			def original_attributes
				(self.send(:persistent_state).send(:original_attributes) rescue { }).inject({ }) do |out, (k, v)|
					out[k.name] = v if attribute?(k.name)
					out
				end
			end


			private

			def persistent_state
				@_persistent_state ||= NotPersisted.new(self)
			end


			def persistent_state=(state)
				@_persistent_state = state || persistent_state
			end


		end
	end
end


