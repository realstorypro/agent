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

ActiveRecord::Schema.define(version: 2022_01_28_140313) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "companies", force: :cascade do |t|
    t.string "name"
    t.jsonb "fields"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.boolean "found", default: false
    t.boolean "error", default: false
    t.boolean "exported", default: false
    t.boolean "scraped_company", default: false
    t.boolean "scraped_contacts", default: false
    t.index ["name"], name: "index_companies_on_name", unique: true
  end

  create_table "contacts", force: :cascade do |t|
    t.string "first_name"
    t.string "last_name"
    t.jsonb "fields"
    t.bigint "company_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.boolean "uploaded", default: false
    t.boolean "enriched", default: false
    t.boolean "invalid_email", default: false
    t.string "email"
    t.boolean "no_address"
    t.index ["company_id"], name: "index_contacts_on_company_id"
  end

end
