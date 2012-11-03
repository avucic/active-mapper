module ActiveMapper
	module Associations
		class AssociationProxy
			attr_reader :relationship, :child, :parent

			def initialize(relationship, child, parent)
				@relationship = relationship
				@child        = child
				@parent       = parent
			end


			def read
				case
					when relationship.kind_of?(BelongsTo)
						@parent ||= fetch_parent
					when relationship.kind_of?(HasOne)
						@child ||= fetch_child
					else
						raise ArgumentError, "Currently #{relationship.inspect} is not supported"
				end
			end

			def query
				case
					when relationship.kind_of?(BelongsTo)
						parent_query
					when relationship.kind_of?(HasOne)
						child_query
					else
						raise ArgumentError, "Currently #{relationship.inspect} is not supported"
				end
			end

			def save(options={ })
				parent.save(options) if parent
				child.save(options) if child
			end

			def inspect
				"#<#{self.class.name} @parent=#{parent.inspect} @child=#{child.inspect}>"
			end

			private

			def child_query
				parent_model.scoped.where(parent_key.name => child_key.get(child)).limit(1).query
			end

			def parent_query
				child_model.scoped.where(child_key.name => parent_key.get(parent)).limit(1).query
			end

			#todo check existance of association key
			def fetch_parent
				attributes = Array.wrap(child_repository.read(child_query)).first
				if attributes
					resource = parent_model.new(attributes)
					resource.send :persistent_state=, Resource::PersistentStates::Persisted.new(resource)
					resource.send :persistent_state=, resource.send(:persistent_state).set_resource
					resource
				end
			end

			#todo check existance of association key
			def fetch_child
				attributes = Array.wrap(parent_repository.read(parent_query)).first
				if attributes
					resource = child_model.new(attributes)
					resource.send :persistent_state=, Resource::PersistentStates::Persisted.new(resource)
					resource.send :persistent_state=, resource.send(:persistent_state).set_resource
					resource
				end
			end


			def child_repository
				@child_repository ||= child_model.repository(child_repository_name || parent_repository_name)
			end

			def parent_repository
				@parent_repository ||= parent_model.repository(parent_repository_name || child_repository_name)
			end

			def child_repository_name
				relationship.child_repository_name
			end

			def parent_repository_name
				relationship.parent_repository_name
			end

			def child_key
				relationship.source_key
			end

			def parent_key
				relationship.parent_key
			end

			def child_model
				relationship.child_model
			end

			def parent_model
				relationship.parent_model
			end
		end
	end
end

