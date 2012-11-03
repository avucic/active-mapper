require File.expand_path(File.dirname(__FILE__)) + '/../spec_helper'
ENV['RACK_ENV'] = "test"

describe "ActiveMapper" do

	describe "Associations" do

		let(:belongs_to) do
			BelongsTo.new(:user, Project, User)
		end

		let(:belongs_to_post) do
			BelongsTo.new(:user, Post, User)
		end

		let(:has_one) do
			HasOne.new(:project, Project, User, { })
		end

		let(:has_many) do
			HasMany.new(:posts, Post, User, { })
		end

		let(:user) { UserService::User.new :title => 'foo' }
		let(:post) { Post.new(:id => 1, :title => 'foo') }
		let(:project) { Project.new(:id => 1, :title => 'foo') }


		describe "All" do


			it "should raise error if different object is provided then what is expected " do
				expect { belongs_to.set(project, Object.new) }.to raise_error
				expect { has_one.set(user, Object.new) }.to raise_error
			end
			it "should not raise error if correct object is passed  " do
				user.id    = 1
				project.id = 1
				expect { belongs_to.set(project, user) }.not_to raise_error
				expect { has_one.set(user, project) }.not_to raise_error
			end
		end


		describe "BelongsTo" do
			it { belongs_to.send(:source_key).name.should == :user_id }

			it { belongs_to.send(:target_key).name.should == :id }

			it { belongs_to.send(:source_model).to_s.should == 'ProjectService::Project' }

			it { belongs_to.send(:target_model).to_s.should == 'UserService::User' }

			it { belongs_to.send(:inverse?).should be_true }

			it "should has HasOne inverse association" do
				belongs_to.send(:inverse).should be_instance_of(has_one.class)
				belongs_to.send(:inverse).source_model.should == has_one.source_model
				belongs_to.send(:inverse).target_model.should == has_one.target_model
			end
		end

		describe "HasOne" do
			it { has_one.send(:source_key).name.should == :user_id }

			it { has_one.send(:target_key).name.should == :id }

			it { has_one.send(:source_model).to_s.should == 'ProjectService::Project' }

			it { has_one.send(:target_model).to_s.should == 'UserService::User' }

			it "should has HasOne inverse association" do
				has_one.send(:inverse).should be_instance_of(belongs_to.class)
				has_one.send(:inverse).source_model.should == has_one.source_model
				has_one.send(:inverse).target_model.should == has_one.target_model
			end

			pending "should set foreign key for the parent association" do
				#has_one.instance_variable_set(:"@foreign_key", :new_foreign_key_id)
				#	has_one.send(:source_key).name.should == :new_foreign_key_id
			end
		end


		describe "HasMany" do
			it { has_many.send(:source_key).name.should == :user_id }

			it { has_many.send(:target_key).name.should == :id }

			it { has_many.send(:source_model).to_s.should == 'PostService::Post' }

			it { has_many.send(:target_model).to_s.should == 'UserService::User' }

			it "should has BelongsTo inverse association" do
				has_many.send(:inverse).should be_instance_of(belongs_to_post.class)
				has_many.send(:inverse).source_model.should == belongs_to_post.source_model
				has_many.send(:inverse).target_model.should == belongs_to_post.target_model
			end


			pending "should set foreign key for the parent association" do
				#has_many.instance_variable_set(:"@foreign_key", :new_foreign_key_id)
				# has_many.send(:source_key).name.should == :new_foreign_key_id
			end
		end


		pending "AssociationCollection"


	end
end


