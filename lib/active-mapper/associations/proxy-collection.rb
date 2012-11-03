module ActiveMapper
	module Associations
		class ProxyCollection

			attr_accessor :repository
			attr_reader :owner, :model, :query

			def initialize(owner)
				@query = owner ? owner.query : Query.new
				@owner = owner
				@model = owner ? owner.model : @query.model
			end

			def repository
				query.repository || @owner.repository
			end


			def get(*args,&block)
				load_or_fetch(query.where(args[0], &block),args[1])
			end

			def find(id,options={})
				load_or_fetch(query.where(owner.key.name => id).limit(1),options)
			end


			def first(n=nil,options={})
				load_or_fetch(query.limit(n || 1),options)
			end


			def last(options={})
				load_or_fetch(query.limit(1).last(true),options)
			end

			def all?
				all.all? { |record| yield(record) }
			end


			def any?
				all.any?
			end

			def empty?
				all.empty?
			end

			def all(options={})
				load_or_fetch(query,options)
			end

			def create(attributes={ }, options={ })
				resource = build(attributes)
				resource.save options
				add resource
				resource
			end


			def update(attributes={ }, options={ })
				all? { |resource| resource.update(attributes, options) }
			end


			def update!(attributes={ }, options={ })
				repository.update(self, attributes, options)
				all.each do |resource|
					resource.run_callbacks :update do
						resource.attributes = attributes
						resource.send(:persistent_state=, resource.send(:persistent_state).update_resource)
					end
				end
			end


			def delete(options={ })
				deleted = all? { |resource| resource.delete(options) }
				records.clear
				deleted
			end


			def delete!(options={ })
				repository.delete(self, options)
				all.each do |resource|
					resource.send :persistent_state=, Resource::PersistentStates::Deleted.new(resource)
					resource.send(:persistent_state=, resource.send(:persistent_state).delete_resource)
				end
				records.clear
				true
			end


			def destroy(options={ })
				if destroyed = all? { |resource| resource.destroy options }
					records.clear
				end
				destroyed
			end

			def destroy!(options={ })
				repository.delete(self, options)
				records.clear
				all? do |resource|
					resource.run_callbacks :destroy do
						resource.send(:persistent_state=, Resource::PersistentStates::Deleted.new(resource))
						resource.send(:persistent_state=, resource.send(:persistent_state).delete_resource)
					end
				end
			end


			def where(q={ }, &block)
				query.where(q, &block)
				self
			end

			def or(q={ }, &block)
				query.or(q, &block)
				self
			end


			def includes(*args)
				to_include    = args.dup
				relationships = model.relationships.select { |rel| to_include.delete(rel.name) }.compact
				raise ArgumentError, "Some of the relationships doesn't exist (#{to_include.join(',')}). Did you forget to define them?" if to_include.any?
				for_idiot = (to_include & (self.query.joins || []))
				raise ArgumentError, "You are trying to include and join the same relationship #{for_idiot.join(',')}. You can't define the same relationship in both places " if for_idiot.any?
				self.query.includes(relationships)
				self
			end


			def joins(*args)
				to_join = args.dup
				klasses = ActiveMapper::Model.descendants.select { |klass| to_join.delete(klass.storage_name) }.compact
				raise ArgumentError, "Some of the classes doesn't exist (#{to_join.join(',')}). Did you forget to define them?" if to_join.any?
				for_idiot = (to_join & (self.query.includes || []))
				raise ArgumentError, "You are trying to include and join the same relationship #{for_idiot.join(',')}. You can't define the same relationship in both places " if for_idiot.any?
				joins = klasses.inject([]) do |out, klass|
					out << { klass.storage_name => klass.scoped.query }
					out
				end
				self.query.joins(joins)
				self
			end


			def scoped
				self
			end


			def build(object={ })
				object.is_a?(Array) ? object.collect { |el| model.build(el) } : model.build(object)
			end


			def each(&block)
				all.each(&block)
			end

			def map(&block)
				all.map(&block)
			end

			def collect(&block)
				all.collect(&block)
			end


			def count
				all.count
			end

			def size
				all.size
			end

			def inspect
				"#<#{self.class.name}:#{object_id} @owner=#{owner.inspect} >"
			end

			protected


			def load_or_fetch(q,options={})
				resources = Array.wrap(records.all(q)).flatten.compact
				unless resources.any?
					resources = Array.wrap(model.send(:build_and_persist, repository.read(q,options)))
					records.replace(resources)
				end
				(q.limit || 0) == 1 ? resources.first : resources
			end


			def remove(resource)
				records.delete(resource)
			end

			def replace(new_resources)
				if new_resources.kind_of?(ProxyCollection)
					replace(resources.send(:collection))
				else
					records.replace new_resources
				end
				new_resources
			end


			def clear
				destroy
			end


			def records
				@records ||= Collection.new
			end

			# support other methods to pump the query
			ScopeMethods::METHODS.each do |method|
				define_method(method) do |args|
					query.send(method, args)
					self
				end unless method_defined?(method)
			end


		end
	end
end

