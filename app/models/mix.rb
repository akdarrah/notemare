class Mix < ActiveRecord::Base
  validates_presence_of :shark_code
  has_and_belongs_to_many :artists
end
