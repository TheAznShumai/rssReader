class Feed < ActiveRecord::Base
  validates :name, :url, presence: true
end
