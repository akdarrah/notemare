class CreateArtists < ActiveRecord::Migration
  def self.up
    create_table :artists do |t|
      t.string :name
      t.text :data
      t.integer :refer_count, :default => 0
      t.integer :fetch_count, :default => 0
      t.timestamp :last_fetch_at
      t.timestamps
    end
  end

  def self.down
    drop_table :artists
  end
end
