require File.expand_path(File.dirname(__FILE__)) + '/../spec_helper'
ENV['RACK_ENV'] = "test"

describe "ActiveMapper" do
	describe "Scope" do


		it "should has default_scope" do
			User.scoped.query.order.should == { :title => "ASC" }
		end


		it "should has default_scope with scope visible" do
			User.visible.where(:title => 'title3').query.to_hash.should =={
					:order => { :title => "ASC" },
					:and   => [
							{ :attribute => :visible, :method_name => :eq, :value => true },
							{ :attribute => :title, :method_name => :eq, :value => "title3" }
					]
			}
		end

		it "should reset internally scope" do
			User.group("title").where(:title => 'title2').query.to_hash.should =={
					:order => { :title => "ASC" },
					:group => "title",
					:and   => [
							{ :attribute => :title, :method_name => :eq, :value => "title2" }
					]
			}
			User.limit(1).group("title").where(:title => 'title2').query.to_hash.should =={
					:order => { :title => "ASC" },
					:group => "title",
					:limit => 1,
					:and   => [
							{ :attribute => :title, :method_name => :eq, :value => "title2" }
					]
			}
			User.where(:title => 'title2').query.to_hash.should =={
					:order => { :title => "ASC" },
					:and   => [
							{ :attribute => :title, :method_name => :eq, :value => "title2" }
					]
			}
			User.visible.where(:title => 'title3').query.to_hash.should =={
					:order => { :title => "ASC" },
					:and   => [
							{ :attribute => :visible, :method_name => :eq, :value => true },
							{ :attribute => :title, :method_name => :eq, :value => "title3" }
					]
			}
			User.visible.published(true).where(:title => 'title3').query.to_hash.should =={
					:order => { :title => "ASC" },
					:and   => [
							{ :attribute => :visible, :method_name => :eq, :value => true },
							{ :attribute => :date, :method_name => :eq, :value => true },
							{ :attribute => :title, :method_name => :eq, :value => "title3" }
					]
			}
			User.where(:title => 'title2').query.to_hash.should =={
					:order => { :title => "ASC" },
					:and   => [
							{ :attribute => :title, :method_name => :eq, :value => "title2" }
					]
			}
		end

		it "should chain scopes" do
			User.visible.published(true).where(:title => 'title3').query.to_hash.should =={
					:order => { :title => "ASC" },
					:and   => [
							{ :attribute => :visible, :method_name => :eq, :value => true },
							{ :attribute => :date, :method_name => :eq, :value => true },
							{ :attribute => :title, :method_name => :eq, :value => "title3" }
					]
			}
		end

	end
end
