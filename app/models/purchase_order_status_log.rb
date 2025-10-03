class PurchaseOrderStatusLog < ApplicationRecord
  belongs_to :purchase_order
  belongs_to :updated_by, class_name: "User"

  validates :status, presence: true

  scope :ordered, -> { order(updated_at: :desc) }
end
