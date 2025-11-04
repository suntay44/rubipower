class MaterialRequisitionSlip < ApplicationRecord
  belongs_to :requester_user, class_name: "User"
  
  # Multi-step approvers
  belongs_to :supervisor_approver, class_name: "User", foreign_key: "supervisor_approved_by", optional: true
  belongs_to :procurement_approver, class_name: "User", foreign_key: "procurement_approved_by", optional: true
  belongs_to :engineering_approver, class_name: "User", foreign_key: "engineering_approved_by", optional: true
  belongs_to :admin_approver, class_name: "User", foreign_key: "admin_approved_by", optional: true
  
  # Associations
  has_many :material_requisition_items, dependent: :destroy
  has_many :materials, through: :material_requisition_items
  has_many :items, dependent: :destroy
  has_many :items_exclusive, -> { where(purchase_request_id: nil) }, class_name: "Item"
  has_many :purchase_request_items, -> { where.not(purchase_request_id: nil) }, class_name: "Item"
  
  # Active Storage attachments for vendor proposals
  has_many_attached :vendor_proposal_1
  has_many_attached :vendor_proposal_2
  has_many_attached :vendor_proposal_3
  
  # Proposals attachment (multiple files)
  has_many_attached :proposals
  
  accepts_nested_attributes_for :material_requisition_items, allow_destroy: true
  # Items are handled manually in controller, not through nested attributes
  
  validates :request_date, presence: true
  validates :purpose, presence: true
  validates :priority_level, presence: true
  
  enum :priority_level, {
    low: "low",
    medium: "medium",
    high: "high",
    urgent: "urgent"
  }, prefix: true
  
  scope :recent, -> { order(created_at: :desc) }
  scope :by_status, ->(status) { where(status: status) if status.present? }
  scope :by_department, ->(dept) { where(department: dept) if dept.present? }
  
  # Approval workflow methods
  def all_approvals_complete?
    supervisor_approved? && procurement_approved? && engineering_approved? && admin_approved?
  end
  
  def current_approval_step
    return :supervisor unless supervisor_approved?
    return :procurement unless procurement_approved?
    return :engineering unless engineering_approved?
    return :admin unless admin_approved?
    :completed
  end
  
  def can_be_approved_by?(user)
    case current_approval_step
    when :supervisor
      user.supervisor?
    when :procurement
      user.procurement?
    when :engineering
      user.department_engineering? && (user.manager? || user.admin?)
    when :admin
      user.admin?
    else
      false
    end
  end
  
  def can_be_edited_by?(user)
    return false if supervisor_approved?
    user == requester_user || user.admin? || user.manager?
  end
end
