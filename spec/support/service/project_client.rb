module ProjectService
	class Project
		include ActiveMapper::Resource

		storage_name :projects


		property :id, Integer, :key => true
		property :title, String
		property :user_id, Integer
		validates_presence_of :title
		belongs_to :user, :class_name => "UserService::User"



	end
end
