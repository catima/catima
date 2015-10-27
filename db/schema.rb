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

ActiveRecord::Schema.define(version: 20151027213627) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "catalog_permissions", force: :cascade do |t|
    t.integer  "catalog_id"
    t.integer  "user_id"
    t.string   "role"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "catalog_permissions", ["catalog_id"], name: "index_catalog_permissions_on_catalog_id", using: :btree
  add_index "catalog_permissions", ["user_id"], name: "index_catalog_permissions_on_user_id", using: :btree

  create_table "catalogs", force: :cascade do |t|
    t.string   "name"
    t.string   "slug"
    t.string   "primary_language", default: "en",  null: false
    t.json     "other_languages"
    t.boolean  "requires_review",  default: false, null: false
    t.datetime "deactivated_at"
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
  end

  add_index "catalogs", ["slug"], name: "index_catalogs_on_slug", unique: true, using: :btree

  create_table "choice_sets", force: :cascade do |t|
    t.integer  "catalog_id"
    t.string   "name"
    t.datetime "deactivated_at"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  add_index "choice_sets", ["catalog_id"], name: "index_choice_sets_on_catalog_id", using: :btree

  create_table "choices", force: :cascade do |t|
    t.integer  "choice_set_id"
    t.text     "long_name_old"
    t.string   "short_name_old"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.json     "short_name"
    t.json     "long_name"
  end

  add_index "choices", ["choice_set_id"], name: "index_choices_on_choice_set_id", using: :btree

  create_table "configurations", force: :cascade do |t|
    t.string   "root_mode",          default: "listing", null: false
    t.integer  "default_catalog_id"
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
  end

  create_table "fields", force: :cascade do |t|
    t.integer  "item_type_id"
    t.integer  "category_item_type_id"
    t.integer  "related_item_type_id"
    t.integer  "choice_set_id"
    t.string   "type"
    t.string   "name_old"
    t.string   "name_plural_old"
    t.string   "slug"
    t.text     "comment"
    t.boolean  "multiple",              default: false, null: false
    t.boolean  "ordered",               default: false, null: false
    t.boolean  "required",              default: true,  null: false
    t.boolean  "i18n",                  default: false, null: false
    t.boolean  "unique",                default: false, null: false
    t.text     "default_value"
    t.json     "options"
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
    t.boolean  "primary",               default: false, null: false
    t.boolean  "display_in_list",       default: true,  null: false
    t.integer  "row_order"
    t.string   "uuid"
    t.json     "name"
    t.json     "name_plural"
  end

  add_index "fields", ["category_item_type_id"], name: "index_fields_on_category_item_type_id", using: :btree
  add_index "fields", ["choice_set_id"], name: "index_fields_on_choice_set_id", using: :btree
  add_index "fields", ["item_type_id", "slug"], name: "index_fields_on_item_type_id_and_slug", unique: true, using: :btree
  add_index "fields", ["item_type_id"], name: "index_fields_on_item_type_id", using: :btree
  add_index "fields", ["related_item_type_id"], name: "index_fields_on_related_item_type_id", using: :btree

  create_table "item_types", force: :cascade do |t|
    t.integer  "catalog_id"
    t.string   "name_old"
    t.string   "slug"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.string   "name_plural_old"
    t.json     "name"
    t.json     "name_plural"
  end

  add_index "item_types", ["catalog_id", "slug"], name: "index_item_types_on_catalog_id_and_slug", unique: true, using: :btree
  add_index "item_types", ["catalog_id"], name: "index_item_types_on_catalog_id", using: :btree

  create_table "items", force: :cascade do |t|
    t.integer  "catalog_id"
    t.integer  "item_type_id"
    t.json     "data"
    t.string   "status"
    t.integer  "creator_id"
    t.integer  "reviewer_id"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  add_index "items", ["catalog_id"], name: "index_items_on_catalog_id", using: :btree
  add_index "items", ["creator_id"], name: "index_items_on_creator_id", using: :btree
  add_index "items", ["item_type_id"], name: "index_items_on_item_type_id", using: :btree
  add_index "items", ["reviewer_id"], name: "index_items_on_reviewer_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "email",                  default: "",    null: false
    t.string   "encrypted_password",     default: "",    null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
    t.boolean  "system_admin",           default: false, null: false
    t.string   "primary_language",       default: "en",  null: false
    t.integer  "invited_by_id"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  add_foreign_key "catalog_permissions", "catalogs"
  add_foreign_key "catalog_permissions", "users"
  add_foreign_key "choice_sets", "catalogs"
  add_foreign_key "choices", "choice_sets"
  add_foreign_key "configurations", "catalogs", column: "default_catalog_id"
  add_foreign_key "fields", "choice_sets"
  add_foreign_key "fields", "item_types"
  add_foreign_key "fields", "item_types", column: "category_item_type_id"
  add_foreign_key "fields", "item_types", column: "related_item_type_id"
  add_foreign_key "item_types", "catalogs"
  add_foreign_key "items", "catalogs"
  add_foreign_key "items", "item_types"
  add_foreign_key "users", "users", column: "invited_by_id"
end
