class AddJobIdToArtist < ActiveRecord::Migration
  def self.up
    add_column :artists, :job_id, :integer, :default => nil
  end

  def self.down
    remove_column :artists, :job_id
  end
end
