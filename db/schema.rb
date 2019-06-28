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

ActiveRecord::Schema.define(version: 2019_06_28_111937) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "pull_tags", force: :cascade do |t|
    t.bigint "pull_id"
    t.bigint "tag_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["pull_id"], name: "index_pull_tags_on_pull_id"
    t.index ["tag_id"], name: "index_pull_tags_on_tag_id"
  end

  create_table "pulls", force: :cascade do |t|
    t.bigint "repo_id"
    t.bigint "user_id"
    t.integer "remote_id", null: false
    t.integer "number", null: false
    t.string "title"
    t.string "body"
    t.integer "status", null: false
    t.datetime "remote_created_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["remote_id"], name: "index_pulls_on_remote_id", unique: true
    t.index ["repo_id"], name: "index_pulls_on_repo_id"
    t.index ["user_id"], name: "index_pulls_on_user_id"
  end

  create_table "repos", force: :cascade do |t|
    t.bigint "user_id"
    t.integer "remote_id"
    t.string "name"
    t.string "full_name"
    t.boolean "private"
    t.bigint "installation_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "description"
    t.string "homepage"
    t.index ["user_id"], name: "index_repos_on_user_id"
  end

  create_table "request_reviews", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "pull_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["pull_id"], name: "index_request_reviews_on_pull_id"
    t.index ["user_id"], name: "index_request_reviews_on_user_id"
  end

  create_table "tags", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "users_github_accounts", force: :cascade do |t|
    t.bigint "user_id"
    t.string "name"
    t.bigint "owner_id"
    t.string "avatar_url"
    t.string "email"
    t.string "nickname"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_users_github_accounts_on_user_id"
  end

  add_foreign_key "pulls", "repos"
  add_foreign_key "pulls", "users"
  add_foreign_key "repos", "users"
  add_foreign_key "request_reviews", "pulls"
  add_foreign_key "request_reviews", "users"
  add_foreign_key "users_github_accounts", "users"
end
