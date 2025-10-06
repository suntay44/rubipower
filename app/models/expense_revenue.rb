class ExpenseRevenue < ApplicationRecord
  belongs_to :requester_user, class_name: "User"
  belongs_to :verified_by, class_name: "User", optional: true
  has_many_attached :receipts
  has_many_attached :supporting_documents

  validates :expense_date, presence: true
  validates :vendor_name, presence: true
  validates :vendor_address, presence: true
  validates :purpose, presence: true
  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :receipt_date, presence: true
  validates :category, presence: true
  validates :sales_order_number, presence: true
  validates :client_name, presence: true

  enum :category, {
    meals_refreshments: 0,
    accommodation: 1,
    equipment: 2,
    office_consumables: 3,
    transportation: 4,
    pms_repair: 5,
    tax: 6,
    payroll: 7,
    hmo: 8,
    charity: 9,
    company_activity: 10,
    contribution: 11
  }

  enum :supervisor_status, {
    pending: 0,
    approved: 1,
    rejected: 2
  }

  enum :finance_status, {
    finance_pending: 0,
    finance_approved: 1,
    finance_rejected: 2
  }

  scope :pending_supervisor, -> { where(supervisor_status: :pending) }
  scope :pending_finance, -> { where(supervisor_status: :approved, finance_status: :finance_pending) }
  scope :approved_payment, -> { where(finance_status: :finance_approved) }
  scope :completed, -> { where.not(verified_at: nil) }

  def total_amount
    quantity.present? && unit_price.present? ? quantity * unit_price : amount
  end
end

