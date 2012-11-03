require "active-mapper/associations/proxy-collection"
require "active-mapper/model/scope"
require "active-mapper/model/storage"
require "active-mapper/model/property"
require "active-mapper/model/dynamic-finders"
require "active-mapper/relationship"
require "active-mapper/query"

module ActiveMapper
	module Model
		extend ActiveSupport::Concern
		delegate *(ScopeMethods::METHODS), :to => :scoped
		def self.descendants
			@descendants ||= []
		end

		included do |klass| #:nodoc: all
			klass.instance_variable_set(:@base_model, klass)
			include Storage
			include Scope
			include Property
			include Relationship
			include DynamicFinders
			ActiveMapper::Model.descendants << klass
		end


		alias_method :model, :class


		module ClassMethods

			def model
				@base_model
			end

			alias :base_model :model

			def repository(name = nil, &block)
				ActiveMapper.repository(name || repository_name, &block)
			end

			def key
				properties.key
			end

			def all(options={})
				scoped.all options
			end


			def build(object=nil)
				case
					when object.kind_of?(NilClass)
						nil
					when object.kind_of?(Hash)
						new(object)
					when object.kind_of?(Array)
						object.collect { |el| build(el) }
					when object.class == self
						object
					else
						raise ArgumentError, "Object to build resource is not supported. #{object.inspect}"
				end
			end

			def first(n=nil,options={})
				scoped.first(n,options)
			end


			def last(options={})
				scoped.last options
			end

			def get(*args, &block)
				scoped.get(*args, &block)
			end

			def find(id,options={})
				scoped.find(id,options)
			end


			def create(attributes = { }, options={ })
				resource = new(attributes)
				resource.save(options) if resource.valid?
				resource
			end

			def destroy(key, options={ })
				raise NotImplementedError, "Currently not supported"
			end

			def delete(key, options={ })
				raise NotImplementedError, "Currently not supported"
			end


			def update(attributes={ }, options={ })
				scoped.update(attributes, options)
			end

			def destroy_all(options={ })
				scoped.destroy(options)
			end

			def delete_all(options={ })
				scoped.delete(options)
			end


			def count
				scoped.count
			end

			alias :size :count
			alias :length :count


			def load(records, query)
				raise NotImplementedError.new "Currently not supported"
			end


			def default_repository_name
				Repository.default_name
			end


			def repository_name(name=nil)
				@_repository_name = name if name
				context           = Repository.context
				@_repository_name ||= context.any? ? context.last.name : default_repository_name
			end

		end

	end


	#fix rails form_for. It will be overridden from resource
	def persisted?
		false
	end


end
