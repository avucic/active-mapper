module ActiveMapper
	module Model
		# == Property
		#
		# Responsible for creating property methods on the including class
		module Property
			extend ActiveSupport::Concern

			included do |klass| #:nodoc: all
				klass.instance_variable_set(:@properties, { })
				repository_name = klass.repository_name || klass.default_repository_name
				klass.properties(repository_name).add(klass, :errors, { })
			end


			class PropertySet < Set #:nodoc: all
				def [](name)
					self.detect { |entry| entry.name == name }
				end

				def key
					self.detect { |entry| entry.key? } || self[:id]
				end


				def add(model, name, options={ })
					super Property::Object.new(model, name, options)
				end
			end


			class Object < ::Object #:nodoc: all
				attr_reader :model, :name, :options, :instance_variable_name, :default, :type

				def initialize(model, name, options = { })

					@model                  = model
					@name                   = name.to_sym
					@options                = options.dup
					@type                   = @options.delete(:type)
					@key                    = @type == Serial
					@instance_variable_name = "@#{@name}".freeze
					@default                = @options.delete(:default)
					accept_value?(@default)
					@options.freeze
				end


				def key
					@key
				end


				def key?
					!!@key
				end

				def is?(value)
					value.to_sym == name
				end


				def get(resource)
					get!(resource)
				end

				def get!(resource)
					resource.instance_variable_get(instance_variable_name) || @default
				end


				def set(resource, value)
					set!(resource, value)
				end


				def set!(resource, value)
			#		raise ArgumentError, "Expected value for attribute #{@name} to be kind of #{@type}. Got : #{value}" unless  accept_value?(value)
					resource.instance_variable_set(instance_variable_name, value || @default)
				end


				def to_hash
					{ name => value }
				end


				private

				def accept_value?(value)
					return true if value.nil?
					value.kind_of? @type
				end




			end


			module ClassMethods

				##
				# Add attribute method on the ActiveMapper::Resource instance
				#
				#  @param [Symbol] name
				#    represent the name of the property
				#
				#  @param [Symbol,Class] type
				#
				#  @param [Hash] options
				#    represent the name of the property
				#
				# ==== Options
				#
				# [:default]
				#   Default value for the attribute.
				#
				def property(name, type, options = { })
					repository_name = options[:repository_name] || self.repository_name || default_repository_name
					property        = properties(repository_name).add(self, name, options.merge({ :type => type }))
					instance_variable_set(:@key, name) if type == Serial
					create_property_methods(name)
					property
				end

				##
				# Return all properties for the class from given  or from default repository
				#
				# @param [Symbol] repository_name
				# @return [Array]
				def properties(repository_name = default_repository_name)
					repository_name                     = repository_name || default_repository_name #if  repository_name is nil
					@properties[repository_name.to_sym] ||= PropertySet.new
				end


				private

				def create_property_methods(method) #:nodoc:
					define_method(method) { instance_variable_get(:"@#{method}") }
					define_method("#{method}=") do |value|
						property = properties[method]
						persistent_state.set(property, value) if property
						persistent_state.get(property)
					end
					define_method("#{method}?") do
						var = instance_variable_get(:"@#{method}")
						!var
					end
				end
			end
		end
	end
end


class Serial < Integer;
end


