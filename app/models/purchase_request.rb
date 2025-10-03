class PurchaseRequest < ApplicationRecord
  belongs_to :requester_user, class_name: "User"
  has_many :items, dependent: :destroy
  has_one_attached :tax_certificate
  has_one_attached :sales_invoice
  has_one_attached :vendor_quotation

  accepts_nested_attributes_for :items, allow_destroy: true

  validates :request_date, presence: true
  validates :priority_level, presence: true
  validates :reason_for_purchase, presence: true

  enum :priority_level, {
    low: "low",
    medium: "medium",
    high: "high",
    urgent: "urgent"
  }

  def budget_approve?
    budget_approve
  end

  def procurement_approve?
    procurement_approve
  end
end
