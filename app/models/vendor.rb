class Vendor < ApplicationRecord
  # Active Storage attachments
  has_one_attached :sample_sales_invoice
  has_one_attached :tax_certificate
  has_one_attached :sales_invoice
  has_one_attached :vendor_quotation

  # Associations
  has_many :products, dependent: :nullify
  has_many :materials, dependent: :nullify
  has_many :items, dependent: :nullify

  # Validations
  validates :name, presence: true, length: { minimum: 2, maximum: 255 }
  validates :address, length: { maximum: 1000 }, allow_blank: true
  validates :tin, length: { maximum: 50 }, allow_blank: true
  validates :bank_details, length: { maximum: 1000 }, allow_blank: true
  validates :status, inclusion: { in: %w[active inactive] }

  # Scopes
  scope :active, -> { where(status: "active") }
  scope :inactive, -> { where(status: "inactive") }
  scope :by_name, -> { order(:name) }
end
