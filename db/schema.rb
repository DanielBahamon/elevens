# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2024_03_09_194112) do

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "calendars", force: :cascade do |t|
    t.datetime "day"
    t.datetime "start_time"
    t.datetime "end_time"
    t.decimal "price", precision: 8, scale: 2
    t.integer "status"
    t.string "user_id"
    t.string "club_id"
    t.string "duel_id"
    t.string "referee_id"
    t.integer "type_reservation"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "club_photos", force: :cascade do |t|
    t.string "club_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "image_file_name"
    t.string "image_content_type"
    t.integer "image_file_size"
    t.datetime "image_updated_at"
    t.index ["club_id"], name: "index_club_photos_on_club_id"
  end

  create_table "clubs", id: { type: :string, limit: 36 }, force: :cascade do |t|
    t.string "user_id", null: false
    t.string "club_name"
    t.string "country"
    t.string "city"
    t.string "neighborhood"
    t.string "members"
    t.string "location"
    t.string "status"
    t.text "summary"
    t.decimal "latitude", precision: 10, scale: 6
    t.decimal "longitude", precision: 10, scale: 6
    t.boolean "private", default: false
    t.boolean "uniform", default: false
    t.boolean "training", default: false
    t.boolean "hydration", default: false
    t.boolean "owner", default: false
    t.boolean "active", default: false
    t.boolean "lockers", default: false
    t.boolean "snacks", default: false
    t.boolean "payroll", default: false
    t.boolean "bathrooms", default: false
    t.boolean "staff", default: false
    t.boolean "assistance", default: false
    t.boolean "roof", default: false
    t.boolean "parking", default: false
    t.boolean "wifi", default: false
    t.boolean "gym", default: false
    t.boolean "showers", default: false
    t.boolean "amenities", default: false
    t.boolean "payment", default: false
    t.boolean "transport", default: false
    t.boolean "lunch", default: false
    t.boolean "videogames", default: false
    t.boolean "air", default: false
    t.boolean "pools", default: false
    t.boolean "perdiem", default: false
    t.boolean "heating", default: false
    t.boolean "washers", default: false
    t.boolean "courses", default: false
    t.integer "price"
    t.integer "duels", default: 0
    t.integer "champions", default: 0
    t.integer "wons", default: 0
    t.string "address"
    t.string "captain"
    t.string "sport"
    t.string "sport_type"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "slug"
    t.string "avatar_file_name"
    t.string "avatar_content_type"
    t.integer "avatar_file_size"
    t.datetime "avatar_updated_at"
    t.boolean "services_ready", default: false
    t.string "main_color", default: "#000000"
    t.string "second_color", default: "#FFFFFF"
    t.boolean "front", default: false
    t.index ["slug"], name: "index_clubs_on_slug", unique: true
    t.index ["user_id"], name: "index_clubs_on_user_id"
  end

  create_table "duel_photos", force: :cascade do |t|
    t.string "duel_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "image_file_name"
    t.string "image_content_type"
    t.integer "image_file_size"
    t.datetime "image_updated_at"
    t.index ["duel_id"], name: "index_duel_photos_on_duel_id"
  end

  create_table "duels", id: { type: :string, limit: 36 }, force: :cascade do |t|
    t.string "rival_id"
    t.string "user_id", null: false
    t.integer "duel_type"
    t.string "address"
    t.string "neighborhood"
    t.string "city"
    t.string "country"
    t.decimal "latitude", precision: 10, scale: 6
    t.decimal "longitude", precision: 10, scale: 6
    t.string "height"
    t.integer "members"
    t.integer "substitutes", default: 0
    t.string "duration"
    t.decimal "price", precision: 8, scale: 2
    t.decimal "budget", precision: 8, scale: 2
    t.decimal "budget_place", precision: 8, scale: 2
    t.decimal "budget_equipment", precision: 8, scale: 2
    t.decimal "referee_price", precision: 8, scale: 2
    t.integer "duration_time"
    t.integer "duration_goals"
    t.integer "goals"
    t.integer "duel_total"
    t.string "place"
    t.string "place_type"
    t.string "referee_name"
    t.string "referee_type"
    t.integer "showerbaths"
    t.integer "bathrooms"
    t.string "audience_type"
    t.string "name"
    t.string "location"
    t.string "listing"
    t.text "summary"
    t.integer "status", default: 0
    t.string "duel_class"
    t.integer "sport"
    t.string "sport_type"
    t.boolean "active", default: false
    t.boolean "responsibility", default: false
    t.boolean "lockers", default: false
    t.boolean "private", default: false
    t.boolean "parking", default: false
    t.boolean "is_internet", default: false
    t.boolean "refreshment", default: false
    t.boolean "refreshment_summary", default: false
    t.boolean "audience", default: false
    t.boolean "referee", default: false
    t.boolean "sport_bib", default: false
    t.boolean "digital_counter", default: false
    t.boolean "streaming", default: false
    t.boolean "snacks", default: false
    t.datetime "start_date"
    t.datetime "end_date"
    t.integer "local_score", default: 0
    t.integer "rival_score", default: 0
    t.string "referee_id"
    t.string "local_formation"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "clubs_id"
    t.string "club_id"
    t.string "formation"
    t.boolean "serviceconfirmation", default: false
    t.boolean "showformation", default: false
    t.integer "time_type"
    t.integer "ready_time"
    t.boolean "ready", default: false
    t.string "color_local"
    t.string "color_rival"
    t.index ["club_id"], name: "index_duels_on_club_id"
    t.index ["clubs_id"], name: "index_duels_on_clubs_id"
    t.index ["user_id"], name: "index_duels_on_user_id"
  end

  create_table "fields", id: { type: :string, limit: 36 }, force: :cascade do |t|
    t.string "user_id"
    t.boolean "approve", default: false
    t.integer "status", default: 0
    t.string "position"
    t.string "name"
    t.string "location"
    t.string "country"
    t.string "city"
    t.string "neighborhood"
    t.string "address"
    t.decimal "latitude", precision: 10, scale: 6
    t.decimal "longitude", precision: 10, scale: 6
    t.boolean "bathrooms", default: false
    t.boolean "parking", default: false
    t.boolean "wifi", default: false
    t.boolean "roof", default: false
    t.boolean "showers", default: false
    t.boolean "store", default: false
    t.boolean "waterfree", default: false
    t.boolean "videogames", default: false
    t.boolean "gym", default: false
    t.boolean "lockers", default: false
    t.boolean "snacks", default: false
    t.boolean "uniform", default: false
    t.boolean "private", default: false
    t.boolean "active", default: false
    t.integer "duels", default: 0
    t.integer "capacity"
    t.integer "price", default: 0
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "slug"
    t.index ["slug"], name: "index_fields_on_slug", unique: true
  end

  create_table "friendly_id_slugs", force: :cascade do |t|
    t.string "slug", null: false
    t.integer "sluggable_id", null: false
    t.string "sluggable_type", limit: 50
    t.string "scope"
    t.datetime "created_at"
    t.index ["slug", "sluggable_type", "scope"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type_and_scope", unique: true
    t.index ["slug", "sluggable_type"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type"
    t.index ["sluggable_type", "sluggable_id"], name: "index_friendly_id_slugs_on_sluggable_type_and_sluggable_id"
  end

  create_table "friendships", force: :cascade do |t|
    t.string "follower_id"
    t.string "followed_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["followed_id"], name: "index_friendships_on_followed_id"
    t.index ["follower_id", "followed_id"], name: "index_friendships_on_follower_id_and_followed_id", unique: true
    t.index ["follower_id"], name: "index_friendships_on_follower_id"
  end

  create_table "goals", force: :cascade do |t|
    t.string "user_id"
    t.string "duel_id"
    t.string "club_id"
    t.string "champion_id"
    t.datetime "time"
    t.integer "total"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "invitations", force: :cascade do |t|
    t.string "user_id"
    t.string "club_id"
    t.string "duel_id"
    t.string "champion_id"
    t.string "rival_id"
    t.string "referee_id"
    t.string "cel"
    t.string "email"
    t.string "text"
    t.string "title"
    t.string "link"
    t.string "link_register"
    t.string "token"
    t.boolean "approved", default: false
    t.boolean "rejected", default: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "lines", force: :cascade do |t|
    t.string "duel_id", null: false
    t.string "club_id", null: false
    t.string "user_id"
    t.boolean "approve", default: false
    t.integer "status", default: 0
    t.string "membership"
    t.integer "number"
    t.string "position"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.boolean "reject"
    t.index ["club_id"], name: "index_lines_on_club_id"
    t.index ["duel_id"], name: "index_lines_on_duel_id"
  end

  create_table "memberships", force: :cascade do |t|
    t.string "user_id", null: false
    t.string "club_id", null: false
    t.boolean "active", default: false
    t.string "boolean", default: "f"
    t.string "slug"
    t.string "firstname"
    t.string "lastname"
    t.integer "status", default: 0
    t.string "position"
    t.integer "number"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "maker_id"
    t.index ["club_id"], name: "index_memberships_on_club_id"
    t.index ["user_id"], name: "index_memberships_on_user_id"
  end

  create_table "notifications", force: :cascade do |t|
    t.string "recipient_type", null: false
    t.string "recipient_id", null: false
    t.string "sender_type"
    t.string "sender_id"
    t.string "content"
    t.string "notification_type"
    t.string "notifiable_id"
    t.string "url"
    t.integer "category", default: 0
    t.integer "action", default: 0
    t.string "club_id"
    t.string "user_id"
    t.string "duel_id"
    t.string "champion_id"
    t.json "params"
    t.datetime "read_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["read_at"], name: "index_notifications_on_read_at"
    t.index ["recipient_type", "recipient_id"], name: "index_notifications_on_recipient"
    t.index ["sender_type", "sender_id"], name: "index_notifications_on_sender"
  end

  create_table "referees", id: { type: :string, limit: 36 }, force: :cascade do |t|
    t.string "user_id"
    t.string "firstname"
    t.string "lastname"
    t.string "slug"
    t.integer "position"
    t.integer "price", default: 0
    t.boolean "active", default: false
    t.boolean "status", default: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "relationships", force: :cascade do |t|
    t.string "follower_id"
    t.string "followed_id"
    t.integer "status", default: 0
    t.boolean "mute", default: false
    t.boolean "blocked", default: false
    t.boolean "active", default: true
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["followed_id"], name: "index_relationships_on_followed_id"
    t.index ["follower_id", "followed_id"], name: "index_relationships_on_follower_id_and_followed_id", unique: true
    t.index ["follower_id"], name: "index_relationships_on_follower_id"
  end

  create_table "reservations", force: :cascade do |t|
    t.string "user_id", null: false
    t.string "duel_id", null: false
    t.string "club_id", null: false
    t.string "referee_id", null: false
    t.integer "position"
    t.datetime "start_date"
    t.datetime "end_date"
    t.integer "price"
    t.decimal "total", precision: 8, scale: 2
    t.boolean "approved", default: false
    t.boolean "rejected", default: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["club_id"], name: "index_reservations_on_club_id"
    t.index ["duel_id"], name: "index_reservations_on_duel_id"
    t.index ["referee_id"], name: "index_reservations_on_referee_id"
    t.index ["user_id"], name: "index_reservations_on_user_id"
  end

  create_table "rivals", force: :cascade do |t|
    t.string "club_id", null: false
    t.string "duel_id", null: false
    t.string "user_id", null: false
    t.string "rival_id"
    t.string "status"
    t.datetime "duel_date"
    t.datetime "start_date"
    t.datetime "end_date"
    t.integer "duel_time"
    t.integer "duel_score"
    t.integer "duel_total"
    t.boolean "approve", default: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["club_id"], name: "index_rivals_on_club_id"
    t.index ["duel_id"], name: "index_rivals_on_duel_id"
    t.index ["user_id"], name: "index_rivals_on_user_id"
  end

  create_table "tasks", force: :cascade do |t|
    t.string "description"
    t.datetime "deadline"
    t.string "status"
    t.string "user_id"
    t.string "club_id"
    t.string "duel_id"
    t.string "url"
    t.boolean "done", default: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.datetime "start_date"
    t.datetime "end_date"
  end

  create_table "users", id: { type: :string, limit: 36 }, force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "firstname"
    t.string "lastname"
    t.text "bio"
    t.datetime "birthday"
    t.boolean "owner"
    t.boolean "partner"
    t.boolean "active"
    t.boolean "live"
    t.integer "praise"
    t.integer "prestige"
    t.string "provider"
    t.string "uid"
    t.string "image"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.integer "height"
    t.integer "favfoot"
    t.integer "favhand"
    t.integer "weakfoot"
    t.integer "weakhand"
    t.integer "skills"
    t.integer "rate"
    t.integer "shot"
    t.integer "pass"
    t.integer "cross"
    t.integer "dribbling"
    t.integer "defense"
    t.integer "physical"
    t.string "slug"
    t.string "avatar_file_name"
    t.string "avatar_content_type"
    t.integer "avatar_file_size"
    t.datetime "avatar_updated_at"
    t.string "sports"
    t.string "position"
    t.integer "number"
    t.string "coverpage_file_name"
    t.string "coverpage_content_type"
    t.integer "coverpage_file_size"
    t.datetime "coverpage_updated_at"
    t.boolean "referee", default: false
    t.boolean "referee_confirmation", default: false
    t.boolean "status", default: false
    t.integer "latitude"
    t.integer "longitude"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["slug"], name: "index_users_on_slug", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "club_photos", "clubs"
  add_foreign_key "clubs", "users"
  add_foreign_key "duel_photos", "duels"
  add_foreign_key "duels", "users"
  add_foreign_key "lines", "clubs"
  add_foreign_key "lines", "duels"
  add_foreign_key "memberships", "clubs"
  add_foreign_key "memberships", "users"
  add_foreign_key "reservations", "clubs"
  add_foreign_key "reservations", "duels"
  add_foreign_key "reservations", "referees"
  add_foreign_key "reservations", "users"
  add_foreign_key "rivals", "clubs"
  add_foreign_key "rivals", "duels"
  add_foreign_key "rivals", "users"
end
