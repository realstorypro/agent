class AddStorageModels < ActiveRecord::Migration[7.0]
  def change
    create_table "companies", force: :cascade do |t|
      t.string "name"
      t.jsonb "fields"
      t.datetime "created_at", precision: 6, null: false
      t.datetime "updated_at", precision: 6, null: false
      t.boolean "found", default: false
      t.boolean "error", default: false
      t.boolean "exported", default: false
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
end
