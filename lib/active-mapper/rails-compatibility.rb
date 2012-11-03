require "active_model"
module ActiveMapper
	module Resource
		extend ActiveSupport::Concern
		included do |klass|
			include ActiveModel::Conversion
			extend ActiveModel::Naming
		end



	end
end
