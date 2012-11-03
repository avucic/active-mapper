module ActiveMapper
	module Associations
		class Association

			attr_reader :name, :instance_variable_name, :options, :foreign_key
			attr_reader :child_repository_name, :parent_repository_name
			attr_reader :parent_key_name, :child_key_name
			attr_reader :parent_model_name, :child_model_name
			attr_reader :parent_association_key, :child_association_key
			attr_reader :parent_association_key_name, :child_association_key_name


			def initialize(name, child_model, parent_model, options = { })
				@name                   = name
				@child_model_name       = child_model.to_s.singularize.camelize
				@instance_variable_name = "@#{@name}".freeze
				@parent_model_name      = parent_model.to_s.singularize.camelize
				@options                = options.dup #.freeze
				@child_repository_name  = @options[:child_repository_name]
				@parent_repository_name = @options[:parent_repository_name]
				@child_key_name         = key_from_class_name(@child_model_name)
				@parent_key_name        = key_from_class_name(@parent_model_name)
			end


			def child_model_name
				@child_model ? child_model.name : @child_model_name
			end

			def parent_model_name
				@parent_model ? parent_model.name : @parent_model_name
			end

			def get(resource, other_query = nil)
				raise NotImplementedError, "#{self.class}#get not implemented"
			end

			def get!(resource)
				resource.instance_variable_get(instance_variable_name)
			end

			def set(resource, association)
				raise NotImplementedError, "#{self.class}#set not implemented"
			end

			def set!(resource, association)
				resource.instance_variable_set(instance_variable_name, association)
			end


			# @return [Property::Object]
			#   return property object for the given association key
			def child_key
				@child_key ||= child_properties[foreign_key || parent_key_name] || child_properties.key
			end

			# @return [Property::Object]
			#   return property object for the given association key
			def parent_key
				@parent_key ||= parent_properties.key
			end


			def child_properties
				return @child_properties if @child_properties
				repository_name   = child_repository_name || parent_repository_name
				properties        = child_model.properties(repository_name)
				@child_properties = properties
			end

			def parent_properties
				return @parent_properties if @parent_properties
				repository_name    = parent_repository_name || child_repository_name
				properties         = parent_model.properties(repository_name)
				@parent_properties = properties
			end


			def child_model?
				!!child_model
			end


			def parent_model?
				!!parent_model
			end


			def child_model
				return @child_model if defined?(@child_model)
				child_model_name = self.child_model_name
				begin
					@child_model = child_model_name.to_s.singularize.camelize.constantize
				rescue
					raise ArgumentError, "Cannot find the child_model #{child_model_name} for #{parent_model_name} " unless @child_model
				end
				@child_model
			end


			def parent_model
				return @parent_model if defined?(@parent_model)
				parent_model_name = self.parent_model_name
				begin
					@parent_model = parent_model_name.to_s.singularize.camelize.constantize
				rescue
					raise ArgumentError, "Cannot find the parent_model #{parent_model_name} for child #{child_model_name} " unless @parent_model
				end
				@parent_model
			end


			def inverse?
				!!inverse
			end

			def inverse
				return @inverse if @inverse
				relationships = inverse_model.relationships(inverse_repository_name)
				@inverse      = relationships.detect do |relationship|
					(relationship.child_model_name == child_model_name) && (relationship.parent_model_name == target_model_name)
				end
			end


			def key_from_class_name(name)
				"#{name.to_s.split('::').last.downcase}_id".to_sym
			end

			# to long in console..let keep it shorter
			def inspect
				"#<#{self.class.name} @child=#{child_model} @parent=#{parent_model} >"
			end

		end
	end
end
