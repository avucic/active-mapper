require 'rubygems'
require 'spork'
#uncomment the following line to use spork with the debugger
#require 'spork/ext/ruby-debug'

Spork.prefork do
	require 'rspec'
	require 'rack/test'
	require "active-mapper"
	require "active-mapper/resource"


	ENV['RACK_ENV'] ||= "test"

	ActiveMapper.register_adapter ActiveMapper::Adapters::InMemoryAdapter ,:default
	Dir[File.join(File.dirname(__FILE__), '..', 'spec/support/*.rb')].each { |f| require f }
	Dir[File.join(File.dirname(__FILE__), '..', 'spec/support/**/*.rb')].each { |f| require f }
	# to skip long namespaces
	include ActiveMapper
	include ActiveMapper::Associations
	include PostService
	include UserService
	include ProjectService
	include CommentService


	RSpec.configure do |config|
		config.include Rack::Test::Methods
		config.before :each do
			ActiveMapper.repository.adapter.clear
		end
	end

end

Spork.each_run do
	Spork.each_run do
		Dir[File.join(File.dirname(__FILE__), '..', 'lib', "active-mapper/*.rb")].each { |f| load f }
		Dir[File.join(File.dirname(__FILE__), '..', 'lib', "active-mapper/resource/**/**/*.rb")].each { |f| load f }
		Dir[File.join(File.dirname(__FILE__), '..', 'lib', "active-mapper/query-builder/**/**/*.rb")].each { |f| load f }
		Dir[File.join(File.dirname(__FILE__), '..', 'lib', "active-mapper/query-builder/**/**/*.rb")].each { |f| load f }
		Dir[File.join(File.dirname(__FILE__), '..', 'lib', "active-mapper/model/**/**/*.rb")].each { |f| load f }
		Dir[File.join(File.dirname(__FILE__), '..', 'lib', "active-mapper/associations/**/**/*.rb")].each { |f| load f }
		Dir[File.join(File.dirname(__FILE__), '..', 'lib', "active-mapper/adapters/**/**/*.rb")].each { |f| load f }
	end

end
