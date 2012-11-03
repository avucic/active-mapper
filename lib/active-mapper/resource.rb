require "active-mapper/model"
require "active-mapper/resource/persistent-states"
require "active-mapper/resource/comparison"
require "active-mapper/resource/validations"


module ActiveMapper
	module Resource
		extend ActiveSupport::Concern #we need that for the ActiveModel::Callbacks
		include Comparison

		included do |klass|
			include Model
			include PersistentStates
			include Validations
			extend ActiveModel::Callbacks
			define_model_callbacks :save, :create, :destroy, :update, :commit
			property :id, Serial
		end


		########################################################################
		#                            Query                                     #
		########################################################################

		def match_query?(query)
			query.match?(attributes)
		end


		def query
			repository.new_query(model)
		end

		def query_for_self
			query.where(properties.key.name => properties.key.get(self))
		end

		def collection_for_self
			collection       = Collection.new(self)
			collection.query = query_for_self
			collection
		end


		########################################################################
		#                            ATTRIBUTES                                #
		########################################################################

		def attribute?(name)
			!!attributes[name]
		end

		def read_attribute(name)
			properties[name.to_sym].get(self) rescue nil
		end

		alias_method :[], :read_attribute

		def write_attribute(name, value)
			property = properties[name]
			self.persistent_state = persistent_state.set(property, value) if property
		end

		alias_method :[]=, :write_attribute

		def attributes
			properties.inject({ }) do |out, property|
				out[property.name] = property.get(self) unless property.name == :errors # temp fix
				out
			end
		end

		alias :to_hash :attributes
		alias :as_json :attributes

		def attribute?(value)
			attributes.key?(value.to_sym)
		end

		def attributes=(attributes={ })
			raise ArgumentError, "To assing attributes to the resource, attributes should be kind_of? Hash. Got:#{attributes.inspect} " unless attributes.kind_of?(Hash)
			attributes.each do |object, value|
				send("#{object}=", value)
			end unless attributes.nil? || attributes.empty?
		end


		########################################################################
		#                            PROPERTIES                                #
		########################################################################

		def key
			@key ||= properties.key
		end
		def to_key
			key.get(self)
		end

		def repository_name
			repository.name
		end

		def repository
			#defined?(@_repository) ? @_repository : model.repository
			model.repository
		end

		def properties
			model.properties(repository_name)
		end

		def relationships
			model.relationships(repository_name)
		end


		########################################################################
		#                            PERSISTENT ACTIONS                       #
		########################################################################

		def update(attributes, options={ })
			run_once(true) do
				run_callbacks :update do
					self.attributes = attributes
					save options
				end
			end

		end

		def update!(attributes, options={ })
			raise "Not Implemented Error"
		end

		def destroy(options={ })
			return true if destroyed?
			run_once(true) do
				run_callbacks :destroy do
					_destroy options
				end
			end
			destroyed?
		end


		def delete(options={ })
			return true if destroyed?
			run_once(true) do
				_destroy options
			end
			destroyed?
		end

		def save(options={ })
			_save options
		end

		# too long in console..let keep it shorter
		def inspect
			attributes.inject("#<#{model.name}  ") do |out, (k, v)|
				out << "@#{k}=#{v.nil? ? 'nil' : v}"
				out << " "
				out
			end << '>'
		end


		private


		def _destroy(options={ })
			self.persistent_state = persistent_state.delete
			_persist options
		end

		def _save(options = { })
			return false unless valid?
			run_once(true) do
				run_callbacks :save do
					save_parents(options) && save_self(options) && save_children(options)
				end
			end
			saved?
		end

		def _persist(options={ })
			run_callbacks :commit do
				self.persistent_state = persistent_state.commit(options)
			end
		end


		def initialize(attributes = nil) # :nodoc:
			self.attributes = attributes if attributes
		end

		def parent_relationships
			return if @_child_relationships || @_parent_relationships
			@_parent_relationships, @_child_relationships = relationships.partition do |relationship|
				relationship.kind_of?(Associations::BelongsTo)
			end
			@_parent_relationships                        ||=[]
		end

		# @api private
		def child_relationships
			parent_relationships
			@_child_relationships ||= []
		end


		def save_self(options={ })
			return true if saved?
			run_callbacks(new? ? :create : :update) do
				_persist(options)
			end
			persisted?
		end


		def save_parents(options={ })
			run_once(true) do
				(parent_relationships || []).map do |relationship|
					parent = relationship.get(self)
					return true unless parent
					if parent.send(:save_parents, options) && parent.send(:save_self, options)
						relationship.set(self, parent)
					end
				end.all?
			end
		end

		# Saves the children resources
		#
		# @return [Boolean]
		#   true if the children were successfully saved
		#
		def save_children(options={ })
			child_relationships.map do |relationship|
				next unless (resource = relationship.get!(self))
				resource.send(:save, options)
			end.all?
		end


		#cool trick from datamapper
		def run_once(default)
			caller_method = Kernel.caller(1).first[/`([^'?!]+)[?!]?'/, 1]
			sentinel      = "@_#{caller_method}_sentinel"
			return instance_variable_get(sentinel) if instance_variable_defined?(sentinel)
			begin
				instance_variable_set(sentinel, default)
				yield
			ensure
				remove_instance_variable(sentinel)
			end
		end
	end
end
