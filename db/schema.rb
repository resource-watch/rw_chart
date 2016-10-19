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

ActiveRecord::Schema.define(version: 20161227113446) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "uuid-ossp"
  enable_extension "citext"

  create_table "charts", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.string   "name",                         null: false
    t.string   "slug"
    t.text     "description"
    t.string   "source"
    t.string   "source_url"
    t.string   "authors"
    t.string   "query_url"
    t.jsonb    "chart_config", default: "{}"
    t.integer  "status",       default: 0
    t.boolean  "published",    default: false
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.boolean  "verified",     default: false
    t.uuid     "layer_id"
    t.uuid     "dataset_id"
    t.boolean  "template",     default: false
    t.boolean  "default",      default: false
    t.jsonb    "application",  default: []
    t.index ["chart_config"], name: "index_charts_on_chart_config", using: :gin
    t.index ["published"], name: "index_charts_on_published", using: :btree
    t.index ["status"], name: "index_charts_on_status", using: :btree
  end

end
