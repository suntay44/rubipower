class SaleItem < ApplicationRecord
  # Associations
  belongs_to :sale
  belongs_to :product

  # Validations
  validates :quantity, presence: true, numericality: { greater_than: 0 }
  validates :unit_price, presence: true, numericality: { greater_than: 0 }
  validates :total_price, presence: true, numericality: { greater_than: 0 }

  # Callbacks
  before_validation :calculate_total_price
  before_validation :set_unit_price
  after_create :reduce_product_stock

  # Methods
  def calculate_total_price
    self.total_price = quantity * unit_price if quantity && unit_price
  end

  private

  def set_unit_price
    self.unit_price = product.price if product && unit_price.nil?
  end

  def reduce_product_stock
    product.reduce_stock(quantity)
  end
end
