require "active-mapper/query"

module ActiveMapper
	class Repository
		attr_reader :name


		def scope
			context = Repository.context
			context << self
			begin
				yield self
			ensure
				context.pop
			end
		end


		def adapter
			@adapter ||=
					begin
						adapters = self.class.adapters
						unless adapters.key?(@name)
							raise StandardError.new "Adapter not set: #{@name}. Did you forget to setup?"
						end

						adapters[@name]
					end
		end


		def new_query(model, options = { })
			adapter.new_query(self, model, options)
		end


		def create(resources, options={ })
			adapter.create(resources, options)
		end

		#todo check indentity_map
		def read(query, options={ })
			adapter.read(query, options)
		end


		def update(collection,attributes, options={ })
			adapter.update(collection,attributes,options)
		end

		def delete(collection, options={ })
			adapter.delete(collection,options)
		end

		private

		def initialize(name)
			@name = name.to_sym
		end


		class << self

			def adapters
				@adapters ||= { }
			end

			def default_name
				:default
			end


			def context
				Thread.current[:active_mapper_repository_contexts] ||= []
			end

		end
	end
end
