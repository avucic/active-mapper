module UserService
	class User
		include ActiveMapper::Resource
		default_scope order(:title => 'ASC')
		storage_name :users
		scope :published, lambda { |date| where(:date => date) }
		scope :visible, where(:visible => true)
		scope :cheep, where { price< 5 }


		property :id, Integer, :key => true
		property :title, String


		validates_presence_of :title
		has_one :project, :class_name => "ProjectService::Project"
		has_many :posts, :class_name => "PostService::Post", :dependent => :destroy


	end
end
