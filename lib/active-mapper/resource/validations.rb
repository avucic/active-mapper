require "active_model"
require "active_model/errors"
module ActiveMapper
	module Resource
		module Validations
			extend ActiveSupport::Concern

			included do |klass|
				include ActiveModel::Validations
				klass.class_eval do
					def run_validations!
						run_callbacks :validate do
							merge_errors(@errors_to_merge)
							errors.empty?
						end
					end

					def valid?
						errors.clear
						run_validations!
					end
				end
			end


			def errors=(attributes)
			 @errors_to_merge = attributes
				merge_errors(@errors_to_merge)
			end




			private

			def merge_errors(args)
				Array.wrap(args).flatten.each do |error|
					case
						when error.kind_of?(String)
							self.errors.add(:base, error)
						when error.kind_of?(Hash)
							error.each do |attribute, message|
								Array.wrap(message).each { |msg| self.errors.add(attribute.to_sym, msg) }
							end
						when error.kind_of?(Array)
							merge_errors(error)
					end
				end
				nil
			end

		end
	end
end
