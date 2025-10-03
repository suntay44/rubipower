class PurchaseOrder < ApplicationRecord
  belongs_to :purchase_request
  has_many :purchase_order_status_logs, dependent: :destroy
  has_one_attached :inspection_report

  validates :po_number, presence: true, uniqueness: true
  validates :status, presence: true
  validates :total_amount, presence: true, numericality: { greater_than: 0 }

  enum :status, {
    draft: "draft",
    approved: "approved",
    sent: "sent",
    goods_received: "goods_received",
    invoice_matched: "invoice_matched",
    payment_processed: "payment_processed",
    cancelled: "cancelled"
  }

  before_validation :generate_po_number, on: :create

  private

  def generate_po_number
    self.po_number = "PO-#{Time.current.strftime('%Y%m%d')}-#{SecureRandom.hex(4).upcase}"
  end
end
