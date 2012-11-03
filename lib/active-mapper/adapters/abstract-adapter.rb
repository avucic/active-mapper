module ActiveMapper
	module Adapters

		class AbstractAdapter


			attr_reader :name
			attr_reader :options


			def initialize(name, options={ })
				@name = name
				@options = options.dup rescue { }
			end

			def new_query(repository, model, options = { })
				query            = Query.new(options)
				query.model      = model
				query.repository = repository
				query
			end


			def create(*args)
				raise NotImplementedError, "#{self.class}#create not implemented"
			end


			def publish(*args)
				raise NotImplementedError, "#{self.class}#publish not implemented"
			end

			def log(*args)
				raise NotImplementedError, "#{self.class}#log not implemented"
			end


			def read(*args)
				raise NotImplementedError, "#{self.class}#read not implemented"
			end


			def update(*args)
				raise NotImplementedError, "#{self.class}#update not implemented"
			end


			def delete(*args)
				raise NotImplementedError, "#{self.class}#delete not implemented"
			end


		end

	end
end

