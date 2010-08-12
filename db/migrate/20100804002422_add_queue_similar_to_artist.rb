class AddQueueSimilarToArtist < ActiveRecord::Migration
  def self.up
    add_column :artists, :queue_similar, :boolean, :default => true
  end

  def self.down
    remove_column :artists, :queue_similar
  end
end
