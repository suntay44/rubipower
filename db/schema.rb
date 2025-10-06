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

ActiveRecord::Schema[8.0].define(version: 2025_10_04_190649) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

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
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "cash_advance_requests", force: :cascade do |t|
    t.string "employee_name", null: false
    t.string "employee_id", null: false
    t.string "department", null: false
    t.string "sales_order_number"
    t.string "client_name"
    t.text "purpose_of_advance", null: false
    t.text "breakdown_of_expenses", null: false
    t.decimal "amount_requested", precision: 10, scale: 2, null: false
    t.date "request_date", null: false
    t.date "required_date", null: false
    t.text "supporting_documents"
    t.string "manager_status", default: "pending"
    t.text "manager_reject_notes"
    t.string "finance_department_status", default: "pending"
    t.text "finance_department_documentation_notes"
    t.bigint "requester_user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "prepare_name"
    t.date "prepare_date"
    t.string "approval_name"
    t.date "approval_date"
    t.string "release_name"
    t.date "release_date"
    t.string "receive_name"
    t.date "receive_date"
    t.index ["finance_department_status"], name: "index_cash_advance_requests_on_finance_department_status"
    t.index ["manager_status"], name: "index_cash_advance_requests_on_manager_status"
    t.index ["requester_user_id"], name: "index_cash_advance_requests_on_requester_user_id"
  end

  create_table "employee_reimbursements", force: :cascade do |t|
    t.string "employee_name"
    t.string "employee_id"
    t.integer "expense_type", default: 0
    t.text "expense_purpose"
    t.decimal "amount_claimed", precision: 10, scale: 2
    t.date "expense_date"
    t.string "sales_order_number"
    t.string "client_name"
    t.integer "supervisor_status", default: 0
    t.text "supervisor_comments"
    t.integer "finance_status", default: 0
    t.text "finance_comments"
    t.integer "payment_method"
    t.date "payment_processed_date"
    t.bigint "requester_user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["expense_type"], name: "index_employee_reimbursements_on_expense_type"
    t.index ["finance_status"], name: "index_employee_reimbursements_on_finance_status"
    t.index ["requester_user_id"], name: "index_employee_reimbursements_on_requester_user_id"
    t.index ["supervisor_status"], name: "index_employee_reimbursements_on_supervisor_status"
  end

  create_table "expense_reports", force: :cascade do |t|
    t.bigint "cash_advance_request_id", null: false
    t.text "explanation"
    t.integer "unused_cash", default: 0
    t.bigint "submitted_by_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["cash_advance_request_id"], name: "index_expense_reports_on_cash_advance_request_id"
    t.index ["submitted_by_id"], name: "index_expense_reports_on_submitted_by_id"
  end

  create_table "expense_revenues", force: :cascade do |t|
    t.date "expense_date"
    t.string "vendor_name"
    t.text "vendor_address"
    t.string "vendor_tin"
    t.text "purpose"
    t.decimal "amount"
    t.date "receipt_date"
    t.string "po_number"
    t.string "rfp_number"
    t.string "bank_reference"
    t.decimal "quantity"
    t.decimal "unit_price"
    t.integer "category"
    t.string "sales_order_number"
    t.string "client_name"
    t.integer "supervisor_status"
    t.integer "finance_status"
    t.text "supervisor_comments"
    t.text "finance_comments"
    t.bigint "verified_by_id"
    t.datetime "verified_at"
    t.bigint "requester_user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["category"], name: "index_expense_revenues_on_category"
    t.index ["expense_date"], name: "index_expense_revenues_on_expense_date"
    t.index ["finance_status"], name: "index_expense_revenues_on_finance_status"
    t.index ["requester_user_id"], name: "index_expense_revenues_on_requester_user_id"
    t.index ["supervisor_status"], name: "index_expense_revenues_on_supervisor_status"
    t.index ["verified_by_id"], name: "index_expense_revenues_on_verified_by_id"
  end

  create_table "invoices", force: :cascade do |t|
    t.integer "invoice_type", default: 0
    t.string "company_name"
    t.text "company_address"
    t.string "company_contact"
    t.string "client_name"
    t.string "client_company"
    t.text "client_address"
    t.string "invoice_number"
    t.date "invoice_date"
    t.date "due_date"
    t.text "description"
    t.text "rates_and_quantities"
    t.decimal "total_amount_due", precision: 10, scale: 2
    t.text "payment_instructions"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["invoice_number"], name: "index_invoices_on_invoice_number", unique: true
    t.index ["invoice_type"], name: "index_invoices_on_invoice_type"
  end

  create_table "items", force: :cascade do |t|
    t.bigint "purchase_request_id", null: false
    t.text "description"
    t.integer "quantity"
    t.decimal "cost", precision: 10, scale: 2
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["purchase_request_id"], name: "index_items_on_purchase_request_id"
  end

  create_table "purchase_order_status_logs", force: :cascade do |t|
    t.bigint "purchase_order_id", null: false
    t.string "status"
    t.bigint "updated_by_id", null: false
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["purchase_order_id"], name: "index_purchase_order_status_logs_on_purchase_order_id"
    t.index ["updated_by_id"], name: "index_purchase_order_status_logs_on_updated_by_id"
  end

  create_table "purchase_orders", force: :cascade do |t|
    t.bigint "purchase_request_id", null: false
    t.string "po_number", null: false
    t.string "status", default: "draft", null: false
    t.decimal "total_amount", precision: 10, scale: 2, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "delivery_note"
    t.index ["po_number"], name: "index_purchase_orders_on_po_number", unique: true
    t.index ["purchase_request_id"], name: "index_purchase_orders_on_purchase_request_id"
    t.index ["status"], name: "index_purchase_orders_on_status"
  end

  create_table "purchase_requests", force: :cascade do |t|
    t.bigint "requester_user_id", null: false
    t.date "request_date"
    t.string "priority_level"
    t.text "reason_for_purchase"
    t.string "sales_order_number"
    t.string "client_name"
    t.text "additional_notes"
    t.boolean "budget_approve", default: false
    t.boolean "procurement_approve", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "vendor_name"
    t.text "vendor_address"
    t.text "bank_details"
    t.index ["requester_user_id"], name: "index_purchase_requests_on_requester_user_id"
  end

  create_table "roles", force: :cascade do |t|
    t.string "name", null: false
    t.integer "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_roles_on_name"
    t.index ["user_id", "name"], name: "index_roles_on_user_id_and_name", unique: true
    t.index ["user_id"], name: "index_roles_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string "first_name"
    t.string "last_name"
    t.string "phone_number"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "cash_advance_requests", "users", column: "requester_user_id"
  add_foreign_key "employee_reimbursements", "users", column: "requester_user_id"
  add_foreign_key "expense_reports", "cash_advance_requests"
  add_foreign_key "expense_reports", "users", column: "submitted_by_id"
  add_foreign_key "expense_revenues", "users", column: "requester_user_id"
  add_foreign_key "expense_revenues", "users", column: "verified_by_id"
  add_foreign_key "items", "purchase_requests"
  add_foreign_key "purchase_order_status_logs", "purchase_orders"
  add_foreign_key "purchase_order_status_logs", "users", column: "updated_by_id"
  add_foreign_key "purchase_orders", "purchase_requests"
  add_foreign_key "purchase_requests", "users", column: "requester_user_id"
  add_foreign_key "roles", "users", on_delete: :cascade
end
