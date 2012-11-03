module ActiveMapper
	module Associations
		class OneToOne < Association

			alias :source_key :child_key
			alias :target_key :parent_key
			alias :source_model :child_model
			alias :target_model :parent_model
			alias :target_model_name :parent_model_name
			alias :target_repository_name :parent_repository_name
			alias :source_repository_name :child_repository_name


			def association?(resource)
				resource.kind_of?(AssociationProxy)
			end


			def save
				raise NotImplementedError, "BelongsTo#save is currently not supported "
			end

		end
	end
end

