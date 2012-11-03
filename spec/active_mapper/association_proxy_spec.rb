require File.expand_path(File.dirname(__FILE__)) + '/../spec_helper'
ENV['RACK_ENV'] = "test"

describe "ActiveMapper" do
	describe "AssociationProxy" do


		let!(:user) { User.new(:id => 12, :title => 'foo') }

		let!(:project) { Project.new(:title => 'foo', :user_id => 12) }

		let(:belongs_to) do
			BelongsTo.new(:user, Project, User)
		end
		let(:has_one) do
			HasOne.new(:project, Project, User, { })
		end
		let(:bt_association) do
			AssociationProxy.new(belongs_to, project, user)
		end

		let(:ho_association) do
			AssociationProxy.new(has_one, project, user)
		end

		describe 'For BelongsTo' do

			it "should has project as child" do
				bt_association.child.should == project
			end

			it "should has user as parent" do
				bt_association.parent.should == user
			end

			it "should has child query" do
				bt_association.send(:child_query).to_hash.should == {
						:order => { :title => "ASC" },
						:limit => 1,
						:and => [
								{ :attribute => :id, :method_name => :eq, :value => 12 }
						]
				}
			end
			it "should has parent query" do
				bt_association.send(:parent_query).to_hash.should == {
						:limit    => 1,
						:and => [
								{ :attribute => :user_id, :method_name => :eq, :value => 12 }
						]
				}
			end
		end

		describe 'For HasOne' do

			it "should has project as child" do
				ho_association.child.should == project
			end

			it "should has user as parent" do
				ho_association.parent.should == user
			end

			it "should has child query" do
				ho_association.send(:child_query).to_hash.should == {
						:order => { :title => "ASC" },
						:limit => 1,
						:and   => [
								{ :attribute => :id, :method_name => :eq, :value => 12 }
						]
				}
			end
			it "should has parent query" do
				ho_association.send(:parent_query).to_hash.should == {
						:limit => 1,
						:and   => [
								{ :attribute => :user_id, :method_name => :eq, :value => 12 }
						]
				}
			end
		end
	end
end
