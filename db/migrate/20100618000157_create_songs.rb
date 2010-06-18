class CreateSongs < ActiveRecord::Migration
  def self.up
    create_table :songs do |t|
      t.string :name
      t.references :artist
      t.text :data
      t.integer :fetch_count, :default => 0
      t.timestamp :last_fetch_at
      t.timestamps
    end
  end

  def self.down
    drop_table :songs
  end
end
