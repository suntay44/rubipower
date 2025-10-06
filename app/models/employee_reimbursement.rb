class EmployeeReimbursement < ApplicationRecord
  belongs_to :requester_user, class_name: "User"
  has_many_attached :receipts
  has_many_attached :proof_of_payment
  has_many_attached :travel_itinerary

  validates :employee_name, presence: true
  validates :employee_id, presence: true
  validates :expense_type, presence: true
  validates :expense_purpose, presence: true
  validates :amount_claimed, presence: true, numericality: { greater_than: 0 }
  validates :expense_date, presence: true
  validates :sales_order_number, presence: true
  validates :client_name, presence: true

  enum :expense_type, {
    travel: 0,
    meals_entertainment: 1,
    office_supplies: 2,
    client_meeting_costs: 3
  }

  enum :supervisor_status, {
    pending: 0,
    approved: 1,
    revised: 2,
    rejected: 3
  }

  enum :finance_status, {
    finance_pending: 0,
    finance_approved: 1,
    finance_rejected: 2
  }

  enum :payment_method, {
    bank_transfer: 0,
    cash: 1
  }

  scope :pending_supervisor, -> { where(supervisor_status: :pending) }
  scope :pending_finance, -> { where(supervisor_status: :approved, finance_status: :finance_pending) }
  scope :approved_payment, -> { where(finance_status: :finance_approved) }
  scope :completed, -> { where.not(payment_processed_date: nil) }
end
