class EmployeeReimbursement < ApplicationRecord
  belongs_to :requester_user, class_name: "User"
  belongs_to :cash_advance_request
  # Removed attachments: receipts, proof_of_payment, travel_itinerary

  validates :cash_advance_request_id, presence: true
  validates :description, presence: true
  validates :amount_to_reimburse, presence: true, numericality: { greater_than: 0 }

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
