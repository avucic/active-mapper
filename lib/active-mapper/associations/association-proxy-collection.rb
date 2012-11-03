module ActiveMapper
	module Associations
		#todo should be refactored
		class AssociationProxyCollection < ProxyCollection

			attr_accessor :relationship
			attr_reader :dependent

			def initialize(relationship, owner, other_query=nil)
				@other_query = other_query
				@dependent   = relationship.dependent
				super(owner)
				@relationship = relationship
				@model        = relationship.source_model
				#todo
				@query        = relationship.source_model.scoped.query.update(@other_query).where(relationship.child_key.name => relationship.target_key.get(owner))
				set_defaults
			end

			def add(resources)
				return resources.map { |el| add(el) } if resources.is_a?(Array)
				record = case
					         when resources.kind_of?(ProxyCollection)
						         raise NotImplementedError, "Merging association is currently  not supported"
					         when resources.kind_of?(Hash)
						         model.build(resources)
					         when resources.class == model
						         resources
					         else
						         raise RuntimeError, "Object #{resource} is not supported for this association"
				         end
				set_keys(record)
				replace(record)
				record.save unless owner.new?
				self
			end

			alias :<< :add


			def clear
				case dependent
					when :delete
						delete
					when :destroy
						destroy
					when :nullify
						nullify
					when dependent.nil?
						destroy
					else
						raise ArgumentError, "Option #{dependent} for dependent is not supported"
				end
				records.clear
			end

			def save(options={ })
				raise ArgumentError, "The parent resource #{owner.inspect} must be saved before saving other resource" unless owner.saved?
				set_defaults
			end


			def build(object={ })
				resource = super
				set_keys resource
				resource
			end


			private

			def set_defaults
				return nil if  owner.nil? || owner.new?
				@query = relationship.source_model.scoped.query.where(relationship.child_key.name => relationship.target_key.get(owner))
				records.each do |resource|
					set_keys(resource)
					resource.save
				end
			end


			def set_keys(new_resources)
				inverse = relationship.inverse
				Array.wrap(new_resources).compact.each do |resource|
					resource.send(:persistent_state).set(inverse.source_key, inverse.target_key.get(owner))
					inverse.set!(resource, AssociationProxy.new(inverse, resource, owner))
				end

			end

			def replace(new_resources)
				super
				set_defaults
				new_resources
			end

			def repository
				model.repository(relationship.source_repository_name)
			end


			def nullify
				inverse = relationship.inverse
				all? do |resource|
					inverse.set!(resource, nil)
					resource.send(:persistent_state).set(inverse.source_key, nil)
					resource.save
				end
			end


		end
	end
end

