# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20140113135517) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "data_files", force: true do |t|
    t.string   "name"
    t.string   "ftype"
    t.string   "source"
    t.binary   "data"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "trace_id"
  end

  add_index "data_files", ["name"], name: "index_data_files_on_name", using: :btree
  add_index "data_files", ["trace_id", "ftype", "source"], name: "index_data_files_on_trace_id_and_ftype_and_source", unique: true, using: :btree
  add_index "data_files", ["trace_id", "ftype"], name: "index_data_files_on_trace_id_and_ftype", unique: true, using: :btree
  add_index "data_files", ["trace_id", "source"], name: "index_data_files_on_trace_id_and_source", unique: true, using: :btree

  create_table "implementations", force: true do |t|
    t.string   "name"
    t.string   "algorithm"
    t.integer  "traces_count"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "implementations", ["algorithm"], name: "index_implementations_on_algorithm", using: :btree
  add_index "implementations", ["name"], name: "index_implementations_on_name", using: :btree

  create_table "processed_texts", force: true do |t|
    t.integer  "trace_id"
    t.integer  "user_id"
    t.string   "comment"
    t.binary   "content"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "processed_texts", ["comment"], name: "index_processed_texts_on_comment", using: :btree
  add_index "processed_texts", ["content"], name: "index_processed_texts_on_content", using: :btree
  add_index "processed_texts", ["trace_id"], name: "index_processed_texts_on_trace_id", using: :btree
  add_index "processed_texts", ["user_id"], name: "index_processed_texts_on_user_id", using: :btree

  create_table "sample_points", force: true do |t|
    t.integer "trace_id"
    t.float   "timestamp"
    t.float   "reading"
  end

  add_index "sample_points", ["timestamp", "trace_id"], name: "index_sample_points_on_timestamp_and_trace_id", unique: true, using: :btree
  add_index "sample_points", ["trace_id"], name: "index_sample_points_on_trace_id", using: :btree

  create_table "traces", force: true do |t|
    t.string   "trace_type"
    t.integer  "implementation_id"
    t.integer  "sample_points_count"
    t.string   "plain_text"
    t.string   "cipher_text"
    t.float    "time_scale"
    t.float    "time_offset"
    t.float    "chan1_scale"
    t.float    "chan1_offset"
    t.float    "chan2_scale"
    t.float    "chan2_offset"
    t.integer  "digital_source"
    t.integer  "digital_position"
    t.float    "sampling_rate"
    t.integer  "resistor"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "key"
  end

  add_index "traces", ["cipher_text"], name: "index_traces_on_cipher_text", using: :btree
  add_index "traces", ["implementation_id"], name: "index_traces_on_implementation_id", using: :btree
  add_index "traces", ["key"], name: "index_traces_on_key", using: :btree
  add_index "traces", ["plain_text"], name: "index_traces_on_plain_text", using: :btree

  create_table "users", force: true do |t|
    t.string   "email"
    t.string   "password"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree

end
