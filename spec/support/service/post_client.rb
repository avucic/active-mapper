  module PostService
    class Post
      include ActiveMapper::Resource
      storage_name :posts
      property :id, Integer, :key=>true
      property :title, String
      property :user_id, Integer
      validates_presence_of :title
      scope :visible, where(:visible => true)
      belongs_to :user ,:class_name=> "UserService::User"
    end
  end
