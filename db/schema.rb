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

ActiveRecord::Schema.define(version: 2019_03_21_113302) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "admins", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_admins_on_email", unique: true
    t.index ["reset_password_token"], name: "index_admins_on_reset_password_token", unique: true
  end

  create_table "issue_comments", force: :cascade do |t|
    t.bigint "pull_id"
    t.integer "remote_id"
    t.text "body"
    t.integer "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["pull_id"], name: "index_issue_comments_on_pull_id"
  end

  create_table "notifications", force: :cascade do |t|
    t.bigint "reviewer_id"
    t.bigint "pull_id"
    t.integer "resource_id"
    t.string "resource_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["pull_id"], name: "index_notifications_on_pull_id"
    t.index ["resource_id"], name: "index_notifications_on_resource_id"
    t.index ["resource_type"], name: "index_notifications_on_resource_type"
    t.index ["reviewer_id"], name: "index_notifications_on_reviewer_id"
  end

  create_table "orgs", force: :cascade do |t|
    t.bigint "remote_id"
    t.string "login"
    t.string "avatar_url"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["deleted_at"], name: "index_orgs_on_deleted_at"
  end

  create_table "pulls", force: :cascade do |t|
    t.bigint "repo_id"
    t.integer "resource_id"
    t.string "resource_type"
    t.integer "remote_id", null: false
    t.integer "number", null: false
    t.string "title"
    t.string "body"
    t.integer "status", null: false
    t.string "token", null: false
    t.string "base_label"
    t.string "head_label"
    t.datetime "remote_created_at", null: false
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["deleted_at"], name: "index_pulls_on_deleted_at"
    t.index ["remote_id"], name: "index_pulls_on_remote_id", unique: true
    t.index ["repo_id"], name: "index_pulls_on_repo_id"
    t.index ["resource_id"], name: "index_pulls_on_resource_id"
    t.index ["resource_type"], name: "index_pulls_on_resource_type"
  end

  create_table "repo_analyses", force: :cascade do |t|
    t.bigint "repo_id"
    t.bigint "static_analysis_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["repo_id"], name: "index_repo_analyses_on_repo_id"
    t.index ["static_analysis_id"], name: "index_repo_analyses_on_static_analysis_id"
  end

  create_table "repos", force: :cascade do |t|
    t.integer "resource_id"
    t.string "resource_type"
    t.integer "remote_id"
    t.string "name"
    t.string "full_name"
    t.boolean "private"
    t.bigint "installation_id"
    t.string "token", null: false
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "template"
    t.boolean "analysis", default: false
    t.index ["deleted_at"], name: "index_repos_on_deleted_at"
    t.index ["resource_id"], name: "index_repos_on_resource_id"
    t.index ["resource_type"], name: "index_repos_on_resource_type"
  end

  create_table "review_comment_trees", force: :cascade do |t|
    t.bigint "comment_id"
    t.bigint "reply_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["comment_id"], name: "index_review_comment_trees_on_comment_id"
    t.index ["reply_id"], name: "index_review_comment_trees_on_reply_id"
  end

  create_table "review_comments", force: :cascade do |t|
    t.bigint "reviewer_id"
    t.bigint "review_id"
    t.text "body"
    t.string "path"
    t.integer "position"
    t.bigint "in_reply_to_id"
    t.bigint "remote_id"
    t.integer "status"
    t.integer "event"
    t.boolean "read"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "sha", default: "", null: false
    t.index ["deleted_at"], name: "index_review_comments_on_deleted_at"
    t.index ["review_id"], name: "index_review_comments_on_review_id"
    t.index ["reviewer_id"], name: "index_review_comments_on_reviewer_id"
  end

  create_table "reviewee_orgs", force: :cascade do |t|
    t.bigint "reviewee_id"
    t.bigint "org_id"
    t.integer "role"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["deleted_at"], name: "index_reviewee_orgs_on_deleted_at"
    t.index ["org_id"], name: "index_reviewee_orgs_on_org_id"
    t.index ["reviewee_id"], name: "index_reviewee_orgs_on_reviewee_id"
  end

  create_table "reviewee_tags", force: :cascade do |t|
    t.bigint "reviewee_id"
    t.bigint "tag_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["reviewee_id"], name: "index_reviewee_tags_on_reviewee_id"
    t.index ["tag_id"], name: "index_reviewee_tags_on_tag_id"
  end

  create_table "reviewees", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["confirmation_token"], name: "index_reviewees_on_confirmation_token", unique: true
    t.index ["deleted_at"], name: "index_reviewees_on_deleted_at"
    t.index ["email"], name: "index_reviewees_on_email", unique: true
    t.index ["reset_password_token"], name: "index_reviewees_on_reset_password_token", unique: true
  end

  create_table "reviewees_github_accounts", force: :cascade do |t|
    t.bigint "reviewee_id"
    t.string "login"
    t.string "access_token"
    t.bigint "owner_id"
    t.string "avatar_url"
    t.string "email"
    t.string "user_type"
    t.string "name"
    t.string "nickname"
    t.string "company"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["deleted_at"], name: "index_reviewees_github_accounts_on_deleted_at"
    t.index ["reviewee_id"], name: "index_reviewees_github_accounts_on_reviewee_id"
  end

  create_table "reviewer_pulls", force: :cascade do |t|
    t.bigint "reviewer_id"
    t.bigint "pull_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["pull_id"], name: "index_reviewer_pulls_on_pull_id"
    t.index ["reviewer_id"], name: "index_reviewer_pulls_on_reviewer_id"
  end

  create_table "reviewer_repos", force: :cascade do |t|
    t.bigint "reviewer_id"
    t.bigint "repo_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["repo_id"], name: "index_reviewer_repos_on_repo_id"
    t.index ["reviewer_id"], name: "index_reviewer_repos_on_reviewer_id"
  end

  create_table "reviewers", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.integer "status"
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "address"
    t.string "name"
    t.index ["confirmation_token"], name: "index_reviewers_on_confirmation_token", unique: true
    t.index ["deleted_at"], name: "index_reviewers_on_deleted_at"
    t.index ["email"], name: "index_reviewers_on_email", unique: true
    t.index ["reset_password_token"], name: "index_reviewers_on_reset_password_token", unique: true
  end

  create_table "reviewers_github_accounts", force: :cascade do |t|
    t.bigint "reviewer_id"
    t.string "login"
    t.bigint "owner_id"
    t.string "avatar_url"
    t.string "email"
    t.string "user_type"
    t.string "name"
    t.string "nickname"
    t.string "company"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["deleted_at"], name: "index_reviewers_github_accounts_on_deleted_at"
    t.index ["reviewer_id"], name: "index_reviewers_github_accounts_on_reviewer_id"
  end

  create_table "reviews", force: :cascade do |t|
    t.bigint "pull_id"
    t.bigint "reviewer_id"
    t.bigint "remote_id"
    t.text "body"
    t.text "reason"
    t.integer "event"
    t.string "commit_id"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["commit_id"], name: "index_reviews_on_commit_id"
    t.index ["deleted_at"], name: "index_reviews_on_deleted_at"
    t.index ["pull_id"], name: "index_reviews_on_pull_id"
    t.index ["reviewer_id"], name: "index_reviews_on_reviewer_id"
  end

  create_table "send_mails", force: :cascade do |t|
    t.bigint "reviewer_id"
    t.string "email", default: "", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["reviewer_id"], name: "index_send_mails_on_reviewer_id"
  end

  create_table "static_analyses", force: :cascade do |t|
    t.string "title"
    t.integer "search_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "tags", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "issue_comments", "pulls"
  add_foreign_key "pulls", "repos"
  add_foreign_key "review_comments", "reviewers"
  add_foreign_key "review_comments", "reviews"
  add_foreign_key "reviewees_github_accounts", "reviewees"
  add_foreign_key "reviewers_github_accounts", "reviewers"
  add_foreign_key "reviews", "pulls"
  add_foreign_key "reviews", "reviewers"
  add_foreign_key "send_mails", "reviewers"
end
