require File.expand_path(File.dirname(__FILE__)) + '/../spec_helper'
ENV['RACK_ENV'] = "test"

describe "ActiveMapper" do
  describe "AssociationProxyCollection" do
    let!(:user) { User.new(:id => 12, :title => 'foo') }

    it "should has posts association collection proxy" do
      user.posts.should be_instance_of(AssociationProxyCollection)
    end
    it "should scope and chain child association" do
      user.posts.query.to_hash.should =={
        :and => [
          { :attribute => :user_id, :method_name => :eq, :value => 12 },
        ]
      }
      user.posts.visible.query.to_hash.should =={
        :and => [
          { :attribute => :user_id, :method_name => :eq, :value => 12 },
          { :attribute => :visible, :method_name => :eq, :value => true }
        ]
      }
    end

    it "should delete one by one" do
      user.save
      Post.create(:title => "bla", :user_id => user.id)
      Post.create(:title => "bla", :user_id => user.id)
      user.posts.delete.should be_true
      user.posts.all.should be_empty
    end

    it "should destroy one by one" do
      user.save
      Post.create(:title => "bla", :user_id => user.id)
      user.posts.destroy.should be_true
      user.posts.all.should be_empty
    end

    it "should delete all in one query" do
      user.save
      Post.create(:title => "bla", :user_id => user.id)
      user.posts.delete!.should be_true
      user.posts.all.should be_empty
    end


    it "should update all one by one" do
      user.save
      Post.create(:title => "bla", :user_id => user.id)
      Post.create(:title => "koo", :user_id => user.id)
      user.posts.update(:title => 'boo')
      user.posts.all[0].title.should == 'boo'
      user.posts.all[1].title.should == 'boo'
    end

    it "should update all in one query" do
      user.save
      Post.create(:title => "bla", :user_id => user.id)
      Post.create(:title => "koo", :user_id => user.id)
      user.posts.update!(:title => 'boo')
      user.posts.all[0].title.should == 'boo'
      user.posts.all[1].title.should == 'boo'
    end

    it "should raise error when relation doesn't exist for inclusion" do
      expect { User.includes(:comments) }.to raise_error
    end


    it "should include relationships" do
      User.includes(:posts, :project).scoped.query.includes.map(&:name).flatten.should ==[:project, :posts]
    end

    it "should raise  error when relation doesn't exist for join" do
      expect { User.joins(:nothing) }.to raise_error
    end


    it "should join relationships" do
      User.joins(:comments).scoped.query.joins.map(&:keys).flatten.first.should == :comments
    end


    it "should build relationship objects through attributes hash" do
      user = User.create(:title => 'foo', :posts => [{ :title => 'post' }])
      user.should be_persisted
      user.posts.all.should_not be_empty
      user.posts.first.user_id.should ==user.id
      user.posts.first.title.should =='post'
      user.posts.first.should be_persisted
    end

    it "should return array as default " do
      User.create(:title => 'boo')
      User.first.posts.should be_empty
    end

    it "should return nil  as default " do
      User.first.should be_nil
    end

    describe "adding resource" do

      it "should raise error if resource is not supported" do
        expect { user.posts.add(Object.new) }.to raise_error
      end

      it "should not raise error if resource is  supported" do
        expect { user.posts.add(Post.new(:title => 'boo')) }.not_to raise_error
      end
    end

    describe "includes" do

      it "should not raise error if resource is  supported" do
        expect { user.posts.add(Post.new(:title => 'boo')) }.not_to raise_error
      end
    end


  end
end
