class PurchaseRequest < ApplicationRecord
  belongs_to :requester_user, class_name: "User"
  belongs_to :manager_approver, class_name: "User", foreign_key: "manager_approved_by", optional: true
  belongs_to :finance_approver, class_name: "User", foreign_key: "finance_approved_by", optional: true
  
  has_many :items, dependent: :destroy
  has_one :purchase_order, dependent: :destroy
  belongs_to :material_requisition_slip, optional: true

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

  def all_approvals_complete?
    manager_approved? && finance_approved?
  end
  
  def manager_approved?
    manager_approved == true
  end
  
  def finance_approved?
    finance_approved == true
  end
end
