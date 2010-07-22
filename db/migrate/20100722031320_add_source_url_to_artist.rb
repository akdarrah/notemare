class AddSourceUrlToArtist < ActiveRecord::Migration
  def self.up
    add_column :artists, :source_url, :string
  end

  def self.down
    remove_column :artists, :source_url
  end
end
