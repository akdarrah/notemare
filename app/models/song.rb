class Song < ActiveRecord::Base
  belongs_to :artist
  validates_presence_of :name
  validates_numericality_of :fetch_count
end
