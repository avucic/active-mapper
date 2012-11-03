require File.expand_path(File.dirname(__FILE__)) + '/../spec_helper'
ENV['RACK_ENV'] = "test"


describe "ActiveMapper" do
	let!(:user) { User.new(:title => 'foo') }
	let!(:post) { Post.new(:title => 'foo') }
	let!(:project) { Project.new(:title => 'foo') }


	describe "Resource" do


		describe "Errors" do
			it "should be merged" do
				user.should be_valid
				user.attributes = { :errors => [{ :title => 'dont looks good' }] }
				user.should_not be_valid
				user.errors.should_not be_empty
				user = User.new(:title => 'foo', :errors => [{ :title => 'dont looks good' }])
				user.should_not be_valid
				user.errors.should_not be_empty
			end
		end


		describe "Persistent State: object " do
			it "should be new record" do
				user.should be_new_record
				user.should_not be_destroyed
				user.should_not be_modified
				user.should_not be_readonly
				user.should_not be_persisted
				user.should_not be_locked
			end

			it "should be persisted" do
				user.save
				user.should_not be_new_record
				user.should_not be_destroyed
				user.should_not be_modified
				user.should_not be_readonly
				user.should be_persisted
				user.should_not be_locked
			end

			it "should  be modified" do
				user.save
				user.title ="boo"
				user.should_not be_new_record
				user.should_not be_destroyed
				user.should be_modified
				user.should_not be_readonly
				user.should_not be_persisted
			end

			it "should  be readonly" do
				user.send(:"persistent_state=", Resource::PersistentStates::Readonly.new(user))
				user.should_not be_new_record
				user.should_not be_destroyed
				user.should_not be_modified
				user.should be_readonly
				user.should_not be_persisted
				user.should_not be_locked
			end

			it "should  be destroyed" do
				user.destroy
				user.should_not be_new_record
				user.should be_destroyed
				user.should_not be_modified
				user.should_not be_readonly
				user.should_not be_persisted
				user.should_not be_locked
			end


		end


		describe "Attributes & Validations" do
			it "should be able to set attribute" do
				user = UserService::User.new
				user.should respond_to(:title)
				user.should respond_to(:title?)
				user.should respond_to(:title=)
				user.title = "foo"
				user.title.should == "foo"
				user.should be_valid
			end

			it "should be able to set attribute through constructor" do
				user = User.new(:title => 'foo')
				user.title.should == "foo"
				user.should be_valid
			end

			it "should raise error if attributes are not kind_of Hash" do
				lambda { User.new(:title => 'foo').attributes= "boooo" }.should raise_error
			end

			it "should not be valid" do
				user = User.new
				user.should_not be_valid
			end


			it "should  raise error for setting the not existing attribute " do
				expect { Project.new(:id => 2, :title => 'foo', :some => Object.new) }.to raise_error
			end
		end

		describe "Associations" do
			describe "All" do

				it "should raise error if different object is provided then what is expected " do
					expect { project = Project.new(:id => 2, :title => 'foo', :user => post) }.to raise_error
					expect { project.user = post }.to raise_error
					expect { user = User.new(:id => 2, :title => 'foo', :project => post) }.to raise_error
					expect { user.project = post }.to raise_error
				end

			end

			describe "BelongsTo" do
				it "should set parent to the child " do
					user.save
					project = Project.new(:id => 2, :title => 'foo', :user => user)
					project.save
					project.user = user
					project.user.should ==user
					project.user_id.should ==1
					user.project.should ==project
				end
				it "should set parent to the child through constructor " do
					project = Project.new(:id => 2, :title => 'foo', :user => user)
					project.save
					project.user.should ==user
					project.user_id.should ==1
					user.project.should ==project
				end

				it "should not delete target object " do
					project = Project.new(:id => 2, :title => 'foo', :user => user)
					project.save
					user.save
					project.destroy.should be_true
					project.should be_destroyed
					project.user_id.should be_nil
					user.should be_persisted
					user.project.should be_nil
				end

				it "should set the both sides from belongs_to" do
					user         = User.new(:title => 'foo')
					project      = Project.new(:title => 'foo')
					project.user = user
					project.user.should == user
					user.project.should == project
				end

				it "should set the both sides from belongs_to after save" do
					user    = User.new(:title => 'foo')
					project = Project.new(:title => 'foo')
					project.save
					user.save
					project.user = user
					project.user_id.should == user.id
					project.user.should == user
					user.project.should == project
				end


				it "should  raise error for setting the association with different type of the object " do
					expect { Project.new(:id => 2, :title => 'foo', :user => Object.new) }.to raise_error
				end

			end

			describe "HasOne" do

				it "should set child to the parent " do
					user         = User.new(:id => 2, :title => 'foo')
					user.project =project
					user.project.should ==project
					project.user_id.should ==2
					project.user.should ==user
				end

				it "should set child to the parent through constructor" do
					user = User.new(:id => 2, :title => 'foo', :project => project)
					user.project.should ==project
					project.user_id.should ==2
					project.user.should ==user
				end

				it "should not delete target object without dependent option " do
					project =Project.new(:id => 41, :title => 'foo')
					user    = User.new(:id => 24, :title => 'foo')
					project.save
					user.save
					project.user.should be_nil
					project.user_id.should be_nil
					user.project.should be_nil
					user.destroy.should be_true
					project.should_not be_destroyed
					project.user_id.should be_nil
					project.user.should be_nil
				end


				it "should  delete source object with dependent option to destroy" do
					project_rel = user.relationships[:project]
					options     = project_rel.instance_variable_get(:@options)
					project_rel.instance_variable_set(:@options, options.merge({ :dependent => :destroy }))
					user = User.new(:id => 2, :title => 'foo', :project => project)
					user.save
					user.destroy.should be_true
					user.should be_destroyed
					project.should be_destroyed
					project_rel.instance_variable_set(:@options, options.merge({ :dependent => :destroy }))
				end
				it "should  nullify source object with dependent option to nullify" do
					project_rel = user.relationships[:project]
					options     = project_rel.instance_variable_get(:@options)
					project_rel.instance_variable_set(:@options, options.merge({ :dependent => :nullify }))
					user = User.new(:id => 2, :title => 'foo', :project => project)
					user.save
					project.save
					project.user.should == user
					project.user_id.should == user.id
					user.destroy.should be_true
					user.should be_destroyed
					project.should_not be_destroyed
					project.user.should be_nil
					project.user_id.should be_nil
					project.should be_persisted
					project_rel.instance_variable_set(:@options, options.merge({ :dependent => :destroy }))
				end

				it "should  raise error for setting the association with different type of the object " do
					expect { User.new(:id => 2, :title => 'foo', :project => Object.new) }.to raise_error
				end


				it "should set the both sides from has_one" do
					user         = User.new(:title => 'foo')
					project      = Project.new(:title => 'foo')
					user.project = project
					project.user.should == user
					user.project.should == project
				end


				it "should set the both sides from has_one after save" do
					user    = User.new(:title => 'foo')
					project = Project.new(:title => 'foo')
					project.save
					user.save
					user.project = project
					project.user_id.should == user.id
					project.user.should == user
					user.project.should == project
				end


			end


			describe "HasMany" do
				it "should add record through association" do
					user = User.new(:title => 'foo')
					user.save
					post = Post.new(:title => 'foo')
					post.save
					user.should be_saved
					user.posts << post
					post.should be_saved
					post.user.should == user
					post.user_id.should == user.id
					user.posts.all.should == [post]
				end

				it "should destroy child object" do
					user = User.new(:title => 'foo')
					user.save
					user.posts << post
					user.posts.destroy
					user.posts.all.should ==[]
					post.should be_destroyed
					expect { post.user.should be_nil }.to raise_error

				end
				it "should destroy all associated objects " do
					user = User.new(:title => 'foo')
					user.save
					post = Post.new(:title => 'foo')
					post.save
					post.should be_persisted
					post.id.should_not be_nil
					user.posts << post
					post.user.should == user
					user.destroy.should be_true
					post.should be_destroyed
					user.should be_destroyed
				end
				it "should not destroy all associated objects with dependent nullify " do
					project_rel = user.posts.relationship
					options     = project_rel.instance_variable_get(:@options)
					project_rel.instance_variable_set(:@dependent, :nullify)
					user = User.new(:title => 'foo')
					user.save
					post = Post.new(:title => 'foo')
					post.save
					user.posts << post
					post.user.should == user
					user.destroy.should be_true
					post.should_not be_destroyed
					user.should be_destroyed
					post.user.should be_nil
					post.user_id.should be_nil
					post.should be_persisted
					project_rel.instance_variable_set(:@dependent, :destroy)
				end

				it "should build object" do
					user.save
					post = user.posts.build(:title => 'boo')
					post.should be_new
					post.user.should == user
					post.user_id.should == user.id
					post.user.should == user

				end
				it "should create object" do
					user.save
					post = user.posts.create(:title => 'boo')
					post.should be_persisted
					post.user_id.should == user.id
					post.user.should == user
				end


			end

			describe "From Database" do
				it "should not find associated record " do
					user    = User.new(:id => 30, :title => 'foo')
					project = Project.new(:title => 'foo', :user_id => 30)
					user.id = 240
					user.save
					project.save
					project.user.should be_nil
					user.project.should be_nil
				end

				it "should find associated record from database" do
					user = User.new(:title => 'foo')
					user.save
					project = Project.new(:title => 'foo', :user_id => user.id)
					project.save
					project.user_id.should == user.id
					project.user.should == user
					user.project.should == project
				end

				it "should not find associated record from database" do
					user = User.new(:id => 30, :title => 'foo')
					user.save
					project = Project.new(:title => 'foo', :user_id => 31)
					project.save
					project.user.should be_nil
					user.project.should be_nil
				end

				it "Should find the record by id" do
					user = User.new(:title => 'foo1')
					user.save
					User.get(:id => 1).should == [user]
					User.get(:id => 2).should be_empty
				end
				it "Should find all records" do
					user = User.new(:title => 'foo1')
					user.save
					User.all.should == [user]
				end

				it "Should find first record" do
					user = User.new(:title => 'foo1')
					user.save
					User.first.should == user
				end

			end

			describe "Additional params" do
				it "should be passed to the adapter" do
					user = User.new(:id => 30, :title => 'foo')
					user.repository.adapter.should_receive(:create).with(user, :with_route => 'some route')
					user.save :with_route => 'some route'
				end
			end


			describe "FORMATS" do
				describe "to_hash" do
					it "should be passed to the adapter" do
						User.new(:id => 30, :title => 'foo').as_json.should == { :id => 30, :title => 'foo' }
					end
				end

			end
		end
	end
end
