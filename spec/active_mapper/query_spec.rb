require File.expand_path(File.dirname(__FILE__)) + '/../spec_helper'
ENV['RACK_ENV'] = "test"

# well I know, it's little bit messy, but we need that hash to build query with different adapters
describe "ActiveMapper" do
	describe "Query" do
		describe "Construction" do
			describe "With Block and dynamic methods" do

				it "should build AND query" do
					Query.new { ((name=="john") & (salary > 5)) }.to_hash.should == ({
							:and => [
									{ :attribute => :name, :method_name => :eq, :value => 'john' },
									{ :attribute => :salary, :method_name => :gt, :value => 5 }
							]
					})
				end

				it "should build OR query" do
					Query.new { ((name=="john") | (salary > 5)) }.to_hash.should == ({
							:or => [
									{
											:and => [
													{ :attribute => :name, :method_name => :eq, :value => 'john' }
											]
									},
									{
											:and => [
													{ :attribute => :salary, :method_name => :gt, :value => 5 }
											]
									}
							]
					})
				end

				it "should chain method where and build AND query without passing block to constructor " do
					Query.new.where { ((name=="john") & (salary > 5)) }.to_hash.should == ({
							:and => [
									{ :attribute => :name, :method_name => :eq, :value => 'john' },
									{ :attribute => :salary, :method_name => :gt, :value => 5 }
							]

					})
				end

				it "should chain method where and build OR query without passing block to constructor " do
					Query.new.or { ((name=="john") & (salary > 5)) | ((name!="john") & (salary < 5)) }.to_hash.should == ({
							:or => [
									{
											:and => [
													{ :attribute => :name, :method_name => :eq, :value => "john" },
													{ :attribute => :salary, :method_name => :gt, :value => 5 }
											]
									},
									{
											:and => [
													{ :attribute => :name, :method_name => :not_eq, :value => "john" },
													{ :attribute => :salary, :method_name => :lt, :value => 5 }
											]
									}
							]
					})
				end

				it "should chain method where build AND query with  block as argument to the constructor " do
					Query.new { (name=="t1") & (salary > 1) }.where { ((date=="some_date") & (some_id == 5)) }.to_hash.should == ({
							:and => [
									{ :attribute => :name, :method_name => :eq, :value => 't1' },
									{ :attribute => :salary, :method_name => :gt, :value => 1 },
									{ :attribute => :date, :method_name => :eq, :value => 'some_date' },
									{ :attribute => :some_id, :method_name => :eq, :value => 5 }
							]
					})
				end
				it "should chain method where build OR query with  block as argument to the constructor " do
					Query.new { (name=="t1") & (salary > 1) }.or { ((date=="some_date") & (some_id == 5)) }.to_hash.should == ({
							:or => [
									{
											:and => [
													{ :attribute => :name, :method_name => :eq, :value => "t1" },
													{ :attribute => :salary, :method_name => :gt, :value => 1 }
											]
									},
									{
											:and => [
													{ :attribute => :date, :method_name => :eq, :value => "some_date" },
													{ :attribute => :some_id, :method_name => :eq, :value => 5 }
											]
									}
							]
					})
				end

				it "should build OR query" do
					Query.new { (name== "john") & (salary == 5) | (name== "foo") }.to_hash.should == ({
							:or => [
									{
											:and => [
													{ :attribute => :name, :method_name => :eq, :value => "john" },
													{ :attribute => :salary, :method_name => :eq, :value => 5 }
											]
									},
									{
											:and => [
													{ :attribute => :name, :method_name => :eq, :value => "foo" }
											]
									}
							]
					})
				end
				it "should build  OR  query" do
					Query.new { (mile != 'Ernie%') | ((salary < 50000) & (salary > 50000)) | (name != 'Mile%') }.to_hash.should == ({
							:or => [
									{
											:or => [
													{
															:and => [
																	{ :attribute => :mile, :method_name => :not_eq, :value => "Ernie%" }
															]
													},
													{
															:and => [
																	{ :attribute => :salary, :method_name => :lt, :value => 50000 },
																	{ :attribute => :salary, :method_name => :gt, :value => 50000 }
															]
													}
											]
									},
									{
											:and => [
													{ :attribute => :name, :method_name => :not_eq, :value => "Mile%" }
											]
									}
							]
					})
				end

				it "should build OR query" do
					Query.new { (name =="john") & (salary == 5) }.or { (name == 'foo') & (salary == 6) }.to_hash.should == ({
							:or => [
									{
											:and => [
													{ :attribute => :name, :method_name => :eq, :value => 'john' },
													{ :attribute => :salary, :method_name => :eq, :value => 5 }
											]
									},
									{
											:and => [
													{ :attribute => :name, :method_name => :eq, :value => 'foo' },
													{ :attribute => :salary, :method_name => :eq, :value => 6 }
											]
									}
							]
					})
				end
				it "should build AND query" do
					Query.new.where({ :name => "john", :salary => 5 }).to_hash.should == ({
							:and => [
									{ :attribute => :name, :method_name => :eq, :value => 'john' },
									{ :attribute => :salary, :method_name => :eq, :value => 5 }
							]
					})
				end

				it "should  build OR query" do
					Query.new.where({ :name => "john", :salary => 5 }).or({ :name => 'foo', :salary => 6 }).to_hash.should == ({
							:or => [
									{
											:and => [
													{ :attribute => :name, :method_name => :eq, :value => 'john' },
													{ :attribute => :salary, :method_name => :eq, :value => 5 }
											]
									},
									{
											:and => [
													{ :attribute => :name, :method_name => :eq, :value => 'foo' },
													{ :attribute => :salary, :method_name => :eq, :value => 6 }
											]
									}
							]
					})
				end


			end


		end

		describe "Matching" do
			describe "Operator" do
				#==
				it { Query.new { (name == 'john') }.match?(:name => "john").should be_true }
				it { Query.new { (name == 'john') }.match?(:name => "joterterthn").should be_false }
				#!=
				it { Query.new { (name != 'john') }.match?(:name => "jsdsdohn").should be_true }
				it { Query.new { (name != 'john') }.match?(:name => "john").should be_false }
				#in
				it { Query.new { (name.in(['john'])) }.match?(:name => "john").should be_true }
				it { Query.new { (name.in(['john'])) }.match?(:name => "johsdsdn").should be_false }
				#not_in
				it { Query.new { (name.not_in(['john'])) }.match?(:name => "jasasohn").should be_true }
				it { Query.new { (name.not_in(['john'])) }.match?(:name => "john").should be_false }
				#not_match
				it { Query.new { (name.not_like('john')) }.match?(:name => "asdasdasdasd").should be_true }
				it { Query.new { (name.not_like('john')) }.match?(:name => "john").should be_false }
				#match
				it { Query.new { (name =~ 'john') }.match?(:name => "johnhhh").should be_true }
				it { Query.new { (name =~ 'john') }.match?(:name => "dfsdfsdf").should be_false }
				#gt
				it { Query.new { (number > 7) }.match?(:number => 8).should be_true }
				it { Query.new { (number > 7) }.match?(:number => 5).should be_false }
				#gteq
				it { Query.new { (number >= 7) }.match?(:number => 8).should be_true }
				it { Query.new { (number >= 7) }.match?(:number => 5).should be_false }
				#lt
				it { Query.new { (number < 7) }.match?(:number => 4).should be_true }
				it { Query.new { (number < 7) }.match?(:number => 8).should be_false }
				#lteq
				it { Query.new { (number <= 7) }.match?(:number => 7).should be_true }
				it { Query.new { (number <= 7) }.match?(:number => 8).should be_false }
			end


			describe "Random" do
				it "should match" do
					Query.new.where({ :name => "john", :salary => 6 }).match?(:name => "john", :salary => 6).should be_true
				end
				it "should not match" do
					Query.new.where({ :name => "john", :salary => 6 }).match?(:name => "john", :salary => 5).should be_false
				end
				it "should  match" do
					Query.new.where({ :name => "john", :salary => 6 }).or({ :name => "john2", :salary => 6 }).match?(:name => "john2", :salary => 6).should be_true
				end
				it "should  not match" do
					Query.new.where({ :name => "john", :salary => 6 }).or({ :name => "john2", :salary => 6 }).match?(:name => "john2", :salary => 8).should be_false
				end
				it "should not match" do
					Query.new { (name == 'john') & (salary > 6) }.match?(:name => "john", :salary => 5).should be_false
				end
				it "should not match" do
					Query.new { name == 'john' }.match?(:name => "sdsd").should be_false
				end
				it "should  match" do
					Query.new { name == 'john' }.match?(:name => "john").should be_true
				end
				it "should  match" do
					Query.new { (name == 'john') | (name == 'jack') }.match?(:name => "jack").should be_true
				end
				it "should  not match" do
					Query.new { (name == 'john') | (name == 'jack') }.match?(:name => "jack2").should be_false
				end
				it "should  not  match" do
					Query.new { name =~ 'john' }.match?(:name => "jfgfdfohn staruss").should be_false
				end
				it "should  match" do
					Query.new { (name =~ 'john') }.match?(:name => "john").should be_true
				end

				it "should not match if one condition is matched and other not" do
					Query.new { (name == 'john') & (id == 3) }.match?(:name => "john", :something => "something_else").should_not be_true
				end


				it "should not match if condition is blank" do
					Query.new { }.match?(:name => "john").should_not be_true
				end

				it "should not match if  value is nil" do
					Query.new { }.match?(:name => nil).should_not be_true
				end

			end
		end


		describe "Updating" do
			it "should update query and build AND query" do
				q1 = Query.new.where(:title => 'something')
				q2 = Query.new.where(:salary => 5)
				q3 = q1.update(q2)
				q3.to_hash.should == {
						:and => [
								{ :attribute => :title, :method_name => :eq, :value => 'something' },
								{ :attribute => :salary, :method_name => :eq, :value => 5 }
						]
				}
				q3.match?(:title => 'something', :salary => 5).should be_true
			end

			it "should update query and build OR query" do
				q1 = Query.new.where(:title => 'something')
				q2 = Query.new.or(:title => 'something_else')
				q3 = q1.update(q2)
				q3.to_hash.should == {
						:or => [
								{
										:and => [
												{ :attribute => :title, :method_name => :eq, :value => 'something' },
										]
								},
								{
										:and => [
												{ :attribute => :title, :method_name => :eq, :value => 'something_else' },
										]
								}
						]
				}
				q3.match?(:title => 'something_else').should be_true
			end
			it "should update all" do
				q1 = Query.new.where(:title => 'something').joins(:users)
				q2 = Query.new.where(:salary => 5)
				q3 = q1.update(q2)
				q3.to_hash.should == {
						:joins => :users,
						:and   => [
								{ :attribute => :title, :method_name => :eq, :value => 'something' },
								{ :attribute => :salary, :method_name => :eq, :value => 5 }
						]
				}
			end
		end

		describe "Additional condition" do
			it { Query.new.group(:something).to_hash.should have_key(:group) }
		end

	end
end
