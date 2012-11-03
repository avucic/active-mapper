module ActiveMapper
	module Associations
		class HasMany < Association

			alias :source_key :child_key
			alias :target_key :parent_key
			alias :source_model :child_model
			alias :target_model :parent_model
			alias :target_model_name :parent_model_name
			alias :target_repository_name :parent_repository_name
			alias :source_repository_name :child_repository_name


			alias :inverse_model :source_model
			alias :inverse_repository_name :source_repository_name


			attr_reader :dependent


			def initialize(name, child_model, parent_model, options = { })
				super
				@dependent = options[:dependent]
			end

			def get(source, other_query=nil)
				collection = get!(source)
				unless collection
					collection =collection_for(source, other_query)
					set!(source, collection)
				end
				collection
			end


			def set(source, target)
				if target
					collection = get(source)
					unless target.kind_of?(ProxyCollection)
						collection.clear
						collection.add target unless target.kind_of?(ProxyCollection) #todo support merging collections
					end
					collection.send :set_defaults if target.kind_of?(ProxyCollection) #todi
				end
			end


			def delete(target)
				collection = get(target)
				collection.clear
				set!(target, nil)
			end


			def inverse
				relation = super
				raise ArgumentError, "HasMany relation detect that other side is not BelongsTo. " +
						"The problem is either you trying to associate wrong relation or is the system bug! " unless relation.kind_of?(BelongsTo)
				relation
			end

			private


			def collection_for(source, other_query)
				proxy = AssociationProxyCollection.new(self, source, other_query)
				meta  = class << proxy;
					self;
				end
				source_model.send(:scopes).each do |meth, proxy_scope|
					meta.send(:redefine_method, meth) do |*args|
						self.query.update(proxy_scope.respond_to?(:call) ? proxy_scope.call(*args).query : proxy_scope.query)
						self
					end
				end
				proxy
			end


		end
	end
end

