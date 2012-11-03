require "active_support"
require 'multi_json'
require 'set'
require 'logger'
require 'hris'
$:.unshift(File.expand_path(File.dirname(__FILE__))) unless  $:.include?(File.expand_path(File.dirname(__FILE__)))
require 'active_support/core_ext/hash'
require "active-mapper/core-ext/kernel"
require "active-mapper/collection"

require "active-mapper/adapters"
require "active-mapper/adapters/abstract-adapter"
require "active-mapper/adapters/in-memory-adapter"
require "active-mapper/repository"
require "active-mapper/rails-compatibility"



# == ActiveMapper
#
# todo desc
module ActiveMapper
	extend self
	attr_accessor :include_root_in_json, :logger
	@logger = Logger.new(STDOUT)

	def register_adapter(klass, *args)
		adapter                           = if (klass < ActiveMapper::Adapters::AbstractAdapter)
			                                    klass.new(args[0], args[1])
			                                  else
				                                  Adapters::AbstractAdapter.new(args[0], args[1] || { })
			                                  end
		Repository.adapters[adapter.name] = adapter
	end


	def repository(name = nil)
		context            = Repository.context
		current_repository = if name
			                     name = name.to_sym
			                     context.detect { |repository| repository.name == name }
			                   else
				                   name = Repository.default_name
				                   context.last
			                   end
		unless current_repository
			context << Repository.new(name)
			current_repository = context.last
		end
		if block_given?
			current_repository.scope { |*block_args| yield(*block_args) }
		else
			current_repository
		end
	end

end
 













