module ActiveMapper
	module Adapters
		class InMemoryAdapter < AbstractAdapter


			def read(query, options={ })
				collection = collection_for(query.storage_name)
				records    = filter_records(query, collection)
				logger.info "IN_MEMORY_ADAPTER:".ansi_cyan + ' Read '.ansi_pur + "records: #{records}"
				logger.info "                  " + ' Storage '.ansi_pur + "#{query.storage_name}"
				logger.info "                  " + ' Query '.ansi_pur + "#{query.to_hash}\n"
				results = Array.wrap(records).flatten.compact
				(query.limit || 0) == 1 ? results.first : results
			end

			def create(resource, query=nil)
				collection = collection_for(resource.storage_name)
				resource.key.set(resource, collection.size.succ)
				collection << resource.attributes
				logger.info "IN_MEMORY_ADAPTER:".ansi_cyan + ' Create '.ansi_pur + "resource: #{resource.inspect}"
				logger.info "                  " + ' Storage '.ansi_pur + "#{resource.storage_name}\n"
				resource.attributes
			end


			def update(collection, attributes, options={ })
				records = read(collection.query)
				logger.info "IN_MEMORY_ADAPTER:".ansi_cyan + ' Update '.ansi_pur + "attributes: #{attributes}"
				records.each { |record| record.update(attributes) }.size
				logger.info "                  " + ' Records '.ansi_pur + "#{records}\n"
			end


			def delete(collection, options={ })
				records = collection_for(collection.query.storage_name)
				logger.info "IN_MEMORY_ADAPTER:".ansi_cyan + ' Delete '.ansi_pur + "records: #{records}\n"
				records_to_delete = filter_records(collection.query, records)
				records_to_delete.each { |el| records.delete(el) }
				true
			end

			def clear
				@database = nil
			end

			def database
				@database ||={ }
			end

			def inspect
				"#<#{self.class.name} >"
			end


			private

			def filter_records(query, collection)
				collection.collect { |record| record if query.match?(record) }.compact
			end


			def logger
				ActiveMapper.logger
			end


			def collection_for(storage_name)
				database[storage_name] ||= []
			end

		end
	end
end
