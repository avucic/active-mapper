require File.expand_path(File.dirname(__FILE__)) + '/../spec_helper'
ENV['RACK_ENV'] = "test"

# well I know, it's little bit messy, but we need that hash to build query with different adapters
describe "ActiveMapper" do
	describe "Model" do
		before :each do
			ActiveMapper.repository.adapter.clear
		end

		it "should not be persisted" do
			Model.new.should_not be_persisted
		end


		it "should not respond to save" do
			Model.new.should_not respond_to(:save)
		end
		it "should not  persisted without id" do
			adapter = ActiveMapper.repository.adapter
			adapter.stub(:create).and_return({ :title => 'bomomomoo' })
			user = User.create(:title => 'boo')
			user.id.should be_nil
			user.should_not be_persisted
			user.should be_new
		end

		it "should persisted without id" do
			user = User.create(:title => 'boo')
			user.id.should_not be_nil
			user.should be_persisted
			user.should_not be_new
		end

		it "should  return first record " do
			user = User.create(:title => 'boo')
			user.should == User.first
		end


		it "should  return last record " do
			user = User.create(:title => 'boo')
			user.should == User.last
		end

		it "should count record " do
			User.create(:title => 'boo')
			User.count.should == 1
		end

		it "should find record " do
			user = User.create(:title => 'boo')
			User.find(1).should == user
		end

		it "should find all records " do
			user = User.create(:title => 'boo')
			User.all.should == [user]
		end

		it "should create record " do
			adapter = ActiveMapper.repository.adapter
			adapter.stub(:create).and_return({ "id" => 24, "title" => "booo" })
			user = User.create(:title => 'booo')
			user.id.should_not be_nil
			user.should_not be_new
			user.should be_persisted
		end

		it "should delete all records " do
			User.create(:title => 'boo')
			User.delete_all
			User.all.should be_empty
		end


		it "should return array as default " do
			User.all.should be_empty
		end

		it "should return array as default " do
			User.first.should be_nil
		end


		it "should respond to dynamic finder " do
			User.should respond_to(:find_by_email)
		end
	end
end
