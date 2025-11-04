class Item < ApplicationRecord
  belongs_to :purchase_request, optional: true
  belongs_to :material_requisition_slip, optional: true
  belongs_to :vendor, optional: true
  
  validate :must_belong_to_purchase_request_or_mrs

  validates :name, presence: true, length: { maximum: 255 }
  validates :description, presence: true
  validates :quantity, presence: true, numericality: { greater_than: 0 }
  validates :quoted_price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  
  private
  
  def must_belong_to_purchase_request_or_mrs
    # Check if item belongs to a Purchase Request (either by ID or through association)
    belongs_to_pr = purchase_request_id.present? || purchase_request.present?
    # Check if item belongs to a Material Requisition Slip (either by ID or through association)
    belongs_to_mrs = material_requisition_slip_id.present? || material_requisition_slip.present?
    
    unless belongs_to_pr || belongs_to_mrs
      errors.add(:base, "Item must belong to either a Purchase Request or Material Requisition Slip")
    end
  end
end
