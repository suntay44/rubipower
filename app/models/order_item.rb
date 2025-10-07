class OrderItem < ApplicationRecord
  # Associations
  belongs_to :order
  belongs_to :product

  # Validations
  validates :quantity, presence: true, numericality: { greater_than: 0 }
  validates :unit_price, presence: true, numericality: { greater_than: 0 }
  validates :total_price, presence: true, numericality: { greater_than: 0 }

  # Callbacks
  before_validation :calculate_total_price
  before_validation :set_unit_price

  # Methods
  def calculate_total_price
    self.total_price = quantity * unit_price if quantity && unit_price
  end

  private

  def set_unit_price
    self.unit_price = product.price if product && unit_price.nil?
  end
end
