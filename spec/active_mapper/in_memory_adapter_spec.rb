require File.expand_path(File.dirname(__FILE__)) + '/../spec_helper'
ENV['RACK_ENV'] = "test"


describe "InMemoryAdapter" do

	let(:adapter) { ActiveMapper.repository.adapter }
	let(:users_table) { adapter.database[:users] }


	before :all do
		adapter.clear
	end


	it "should find user by id" do
		user = User.new(:title => 'foo1')
		user.save
		adapter.read(User.scoped.where(:id => user.id).query).should include(user.attributes)
	end

	it "should find user by title" do
		user = User.new(:title => 'foo6')
		user.save
		adapter.read(User.scoped.where(:title => 'foo6').query).should include(user.attributes)
	end
	#
	it "should find user by title and by id" do
		user = User.new(:title => 'john')
		user.save
		adapter.read(User.scoped.where(:id => user.id, :title => 'john').query).should include(user.attributes)
	end
	#
	it "should not find record" do
		user = User.new(:title => 'foo2')
		user.save
		adapter.read(User.scoped.where(:id => 144444, :title => 'fozofdfdf88').query).should be_empty
	end


end


