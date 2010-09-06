class AddNameIndexToArtist < ActiveRecord::Migration
  def self.up
    add_index :artists, [:name], :name => 'index_artists_on_name'
  end

  def self.down
    remove_index :artists, [:name]
  end
end
