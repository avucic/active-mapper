require File.expand_path(File.dirname(__FILE__)) + '/../spec_helper'
ENV['RACK_ENV'] = "test"

# well I know, it's little bit messy, but we need that hash to build query with different adapters
describe "ActiveMapper" do
	describe "Collection" do

		let(:collection) { Collection.new }
		let(:resource) { User.new(:title => 'john') }



		it "should add object" do
			expect { collection.add(resource) }.to change { collection.count }.from(0).to(1)
		end


		it "should delete object" do
			collection.add(resource)
			expect { collection.delete(resource) }.to change { collection.count }.from(1).to(0)
		end

		it "should find one record by title" do
			collection.add(resource)
			collection.all(Query.new { title=='john' }).should == [resource]
		end

		it "should find 2 records by the same title" do
			collection.add(resource)
			collection.add(resource)
			collection.all(Query.new { title=='john' }).should == [resource, resource]
		end


		it "should find record by id" do
			resource.save
			collection << (resource)
			collection.all(Query.new.where({ :id => resource.id })).should == [resource]
		end
		it "should not find record by id" do
			resource.save
			collection << (resource)
			collection.all(Query.new.where({ :id => 123 })).should be_empty
		end

		it "should delete record" do
			resource.save
			collection << (resource)
			collection.delete(resource)
			collection.all(Query.new.where({ :id => resource.id })).should be_empty
		end
		it "should include record" do
			resource.save
			collection << (resource)
			resource.match_query?(User.scoped.where(:title => 'john').query).should be_true
			collection.all(User.scoped.where(:title => 'john').query).should include(resource)
		end

	end
end
