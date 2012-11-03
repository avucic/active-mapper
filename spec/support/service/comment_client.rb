module CommentService
	class Comment
		include ActiveMapper::Resource

		property :id, Integer, :key => true
		property :title, String
	end
end
