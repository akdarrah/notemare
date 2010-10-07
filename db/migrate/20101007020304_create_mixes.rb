class CreateMixes < ActiveRecord::Migration
  def self.up
    create_table :mixes do |t|
      t.string :shark_code
      t.timestamps
    end
  end

  def self.down
    drop_table :mixes
  end
end
