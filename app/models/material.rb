class Material < ApplicationRecord
  # Associations
  belongs_to :vendor
  has_many :material_requisition_items, dependent: :restrict_with_error
  has_many :material_requisition_slips, through: :material_requisition_items

  # Validations
  validates :name, presence: true, length: { minimum: 2, maximum: 255 }
  validates :description, length: { maximum: 2000 }, allow_blank: true
  validates :unit, length: { maximum: 50 }, allow_blank: true
  validates :unit_price, numericality: { greater_than_or_equal_to: 0 }, allow_blank: true
  validates :status, inclusion: { in: %w[active inactive] }

  # Scopes
  scope :active, -> { where(status: "active") }
  scope :inactive, -> { where(status: "inactive") }
  scope :by_name, -> { order(:name) }
  scope :search, ->(query) { where("name ILIKE ? OR description ILIKE ?", "%#{query}%", "%#{query}%") if query.present? }
end
