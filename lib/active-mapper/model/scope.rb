module ActiveMapper
	module Model
		module Scope
			extend ActiveSupport::Concern
			module ClassMethods
				#delegate all  proxy methods which will return current new proxy object for latter merging
				delegate *(ScopeMethods::METHODS), :to => :scoped

				def default_scope(default_proxy = nil)
					@_default_scope ||= { }
					if default_proxy
						@_default_scope[repository_name || default_repository_name] ||= default_proxy
					end
					@_default_scope[repository_name || default_repository_name]
				end

				#todo needs to be cashed?
				# @return [Associations::ProxyCollection]
				#   return proxy collection with default scope
				def scoped
					Associations::ProxyCollection.new(self)
				end


				def with_scope(options)
					raise NotImplementedError, "not supported yet"
				end


				def query
					repository.new_query(model).update(default_scope ? default_scope.query : nil)
				end


				protected


				def scope(name, query=nil)
					define_scope_method(name, query)
				end


				def with_exclusive_scope(query)
					raise NotImeplementedError, "it's not supported yet"
				end


				private


				def define_scope_method(name, scoped_poxy)
					scopes[name] = scoped_poxy
					define_singleton_method(name) do |*args|
						_scoped = scoped
						meta    = class << _scoped;
							self;
						end
						scopes.each do |meth, proxy_scope|
							meta.send(:redefine_method, meth) do |*args|
								self.query.update(proxy_scope.respond_to?(:call) ? proxy_scope.call(*args).query : proxy_scope.query)
								self
							end
						end
						_scoped.send(name, args)
					end unless  respond_to?(name)
				end


				def scopes
					@scopes ||={ }
				end

			end
		end
	end
end
