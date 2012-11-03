module ActiveMapper
	#todo this should be refactored
	class Collection
		include Enumerable
		attr_accessor :query

		def initialize(records = nil)
			@records = [records].compact.flatten
		end

		#todo refactor this
		def add(object)
			case
				when object.respond_to?(:records)
					@records = (@records + object.send(:records)).flatten.compact
				when object.kind_of?(Array)
					@records = (@records + object).flatten.compact
				else
					@records = (@records << object).flatten.compact
			end
			object
		end

		alias :<< :add

		def delete(object)
			case
				when object.respond_to?(:records)
					@records = @records - object.send(:records)
				when object.kind_of?(Array)
					@records = (@records - object).flatten.compact
				when object.kind_of?(Query)
					@records = (@records - all(object)).flatten.compact
				else
					@records.delete(object)
			end
			object
		end

		def first(limit = nil)
			limit ? @records[0..limit] : @records.first
		end

		def last
			@records.last
		end

		def replace(records)
			records = Array.wrap(records).compact
			other   = @records - records
			@records  = other + records
			records
		#	@records = (@records|Array.wrap(records).compact).uniq { |x| x[:id] }
		end

		def + (object)
			raise NotImplementedError, 'Currently not supported'
		end

		def - (object)
			raise NotImplementedError, 'Currently not supported'
		end

		#todo smarter filtering
		def all(query=nil)
			return @records unless query
			query.limit ==1 ? find { |el| el if el.match_query?(query) } :
					collect { |el| el if el.match_query?(query) }.compact
		end


		def each
			@records.each { |record| yield(record) }
		end

		def clear
			@records.clear
		end

		protected

		def records
			@records ||=[]
		end

	end
end



