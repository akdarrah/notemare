# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20100617022326) do

  create_table "artists", :force => true do |t|
    t.string   "name"
    t.text     "data"
    t.text     "similar_data"
    t.string   "shark_code"
    t.integer  "refer_count",   :default => 0
    t.integer  "fetch_count",   :default => 0
    t.datetime "last_fetch_at", :default => '2010-06-28 01:05:53'
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
