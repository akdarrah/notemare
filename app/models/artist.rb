class Artist < ActiveRecord::Base
  validates_presence_of :name
  validates_numericality_of :refer_count, :fetch_count
  has_many :songs, :dependent => :destroy
end
