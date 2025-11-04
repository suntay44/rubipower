class MaterialRequisitionItem < ApplicationRecord
  belongs_to :material_requisition_slip
  belongs_to :material
  
  validates :quantity, presence: true, numericality: { greater_than: 0 }
  validates :material_id, presence: true
end
