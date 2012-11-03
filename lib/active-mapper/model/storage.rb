module ActiveMapper
	module Model
		module Storage
			extend ActiveSupport::Concern

			def storage_name
				storage_name = self.class.instance_variable_get(:@storage_names) || { }
				storage_name[repository.name]
			end


			module ClassMethods


				def storage_name(name= nil, options={ })
					repository_name = repository(options[:repository]).name
					@storage_names  ||={ }
					@storage_names[repository_name] = name if name
					@storage_names[repository_name] ||= self.name.split("::").last.downcase.pluralize.to_sym
				end


			end
		end
	end
end
