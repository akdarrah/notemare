class CreateArtistsMixes < ActiveRecord::Migration
  def self.up
    create_table :artists_mixes, :id => false, :force => true do |t|
      t.integer :artist_id
      t.integer :mix_id
    end
  end

  def self.down
    drop_table :artists_mixes
  end
end
