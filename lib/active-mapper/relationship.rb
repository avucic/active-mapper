require "active-mapper/query"
require "active-mapper/associations/association"
require "active-mapper/associations/association-proxy"
require "active-mapper/associations/proxy-collection"
require "active-mapper/associations/association-proxy-collection"
require "active-mapper/associations/one-to-one"
require "active-mapper/associations/belongs-to"
require "active-mapper/associations/has-many"
require "active-mapper/associations/has-one"

module ActiveMapper
	# == Relationship
	#
	# Responsible for association between Resource
	#
	module Relationship
		extend ActiveSupport::Concern

		class RelationshipSet < Set
			def [](name)
				name = name.to_s
				self.detect { |entry| entry.name.to_s == name }
			end
		end

		included do |klass| #:nodoc: all
			klass.instance_variable_set(:@relationships, { })
		end


		module ClassMethods


			##
			#
			# Specifies a one-to-many association.
			#
			#
			# ==== Options
			#
			# [:class_name]
			#   Specify the class name of the association.
			#
			# [:repository]
			#   Specify the name of the repository to use for fetching associated records. If not provided, default name will be used
			#
			# [:dependent]
			#   Nullify ,Destroy.
			#
			# [:foreign_key]
			#   Specify the foreign key used for the association..
			#
			# @param [Symbol] name
			# @param [Hash]  options
			def has_many(name, options={ })
				name   = name.to_s.pluralize.to_sym
				client = options[:class_name] || name.to_s.singularize.camelize
				raise ArgumentError.new "U have to provide :class_name for the has_many  association" unless client
				repository_name                  = repository.name
				options[:child_repository_name]  = options.delete(:repository)
				options[:parent_repository_name] = repository_name
				association                      = Associations::HasMany.new(name, client, self, options)
				relationships(repository_name) << association
				create_relationship_methods(association)
				association
			end

			##
			#
			# Specifies a one-to-one association.
			#
			#
			# ==== Options
			#
			# [:class_name]
			#   Specify the class name of the association.
			#
			# [:repository]
			#   specify the name of the repository to use for fetching associated records. If not provided, default name will be used
			#
			# [:foreign_key]
			#   Specify the foreign key used for the association..
			#
			# @param [Symbol] name
			# @param [Hash]  options
			def has_one(name, options={ })
				name   = name.to_s.singularize.to_sym
				client = options[:class_name] || name.to_s.singularize.camelize
				raise ArgumentError.new "U have to provide :class_name for the has_one client association" unless client
				repository_name                  = repository.name || default_repository_name
				options[:child_repository_name]  = options.delete(:repository)
				options[:parent_repository_name] = repository_name
				association                      = Associations::HasOne.new(name, client, self, options)
				relationships(repository_name) << association
				create_relationship_methods(association)
				association
			end


			##
			#
			# Specifies a one-to-one association.
			#
			#
			# ==== Options
			#
			# [:class_name]
			#   Specify the class name of the association.
			#
			# [:repository]
			#   Specify the name of the repository to use for fetching associated records. If not provided, default name will be used
			#
			# [:foreign_key]
			#   Specify the foreign key used for the association..
			#
			# @param [Symbol] name
			# @param [Hash]  options
			def belongs_to(name, options={ })
				name   = name.to_s.singularize.to_sym
				client = options[:class_name] || name.to_s.singularize.camelize
				raise ArgumentError.new "U have to provide :class_name for the belongs_to client association" unless client
				repository_name                  = repository.name || :default
				options[:child_repository_name]  = repository_name
				options[:parent_repository_name] = options.delete(:repository)
				association                      = Associations::BelongsTo.new(name, self, client, options)
				relationships(repository_name) << association
				create_relationship_methods(association)
				association
			end


			##
			# Return all relationships by the given  or by default repository name
			def relationships(repository_name = default_repository_name)
				default_repository_name = self.default_repository_name

				@relationships[repository_name] ||= if repository_name == default_repository_name
					                                    RelationshipSet.new
					                                  else
						                                  relationships(default_repository_name).dup
					                                  end
			end


			private
			#create dynamic methods on the Anonymous module rather on the class itself
			def create_relationship_methods(relationship)
				name        = relationship.name
				reader_name = "#{name}"
				writer_name = "#{name}="
				return if method_defined?(reader_name) && method_defined?(writer_name)
				relationship_module.module_eval do
					define_method(reader_name) do
						persistent_state.get(relationships[name], self.query)
					end
					define_method(writer_name) do |target|
						relationship          = relationships[name]
						self.persistent_state = persistent_state.set(relationship, target)
						persistent_state.get(relationship, self.query)
					end
				end
			end





			#return the instance of the Anonymous module which is included to the caller class for creating relationships methods
			def relationship_module
				@relationship_module ||= begin
					mod = Module.new
					class_eval do
						include mod
					end
					mod
				end
			end

		end

	end
end
