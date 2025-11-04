class CashAdvanceRequest < ApplicationRecord
  belongs_to :requester_user, class_name: "User"
  belongs_to :sale, optional: true
  has_many_attached :supporting_documents
  has_one :expense_report, dependent: :destroy

  validates :employee_name, presence: true
  validates :employee_id, presence: true
  validates :department, presence: true
  validates :purpose_of_advance, presence: true
  validates :breakdown_of_expenses, presence: true
  validates :amount_requested, presence: true, numericality: { greater_than: 0 }
  validates :request_date, presence: true
  validates :required_date, presence: true

  enum :manager_status, {
    pending: "pending",
    approved: "approved",
    revised: "revised",
    rejected: "rejected"
  }

  enum :finance_department_status, {
    finance_pending: "pending",
    finance_approved: "approved",
    finance_rejected: "rejected"
  }

  scope :pending_manager_approval, -> { where(manager_status: "pending") }
  scope :approved_by_manager, -> { where(manager_status: "approved") }
  scope :pending_finance_approval, -> { where(manager_status: "approved", finance_department_status: "finance_pending") }
  scope :approved_by_finance, -> { where(finance_department_status: "finance_approved") }
end
