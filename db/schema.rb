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

ActiveRecord::Schema.define(version: 20150911172614) do

  create_table "instances", force: :cascade do |t|
    t.string   "name"
    t.string   "url"
    t.text     "description"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "items", force: :cascade do |t|
    t.integer  "schema_element_id"
    t.text     "data"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
  end

  add_index "items", ["schema_element_id"], name: "index_items_on_schema_element_id"

  create_table "schema_elements", force: :cascade do |t|
    t.string   "name"
    t.text     "description"
    t.integer  "instance_id"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.string   "element_type"
    t.text     "options"
  end

  add_index "schema_elements", ["instance_id"], name: "index_schema_elements_on_instance_id"

  create_table "schema_fields", force: :cascade do |t|
    t.string   "name"
    t.text     "definition"
    t.text     "description"
    t.integer  "schema_element_id"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
  end

  add_index "schema_fields", ["schema_element_id"], name: "index_schema_fields_on_schema_element_id"

  create_table "views", force: :cascade do |t|
    t.string   "view_type"
    t.integer  "instance_id"
    t.string   "slug"
    t.text     "template"
    t.text     "elements"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "views", ["instance_id"], name: "index_views_on_instance_id"

end
