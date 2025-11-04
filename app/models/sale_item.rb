class SaleItem < ApplicationRecord
  # Associations
  belongs_to :sale
  belongs_to :product

  # Validations
  validates :quantity, presence: true, numericality: { greater_than: 0 }
  validates :unit_price, presence: true, numericality: { greater_than: 0 }
  validates :total_price, presence: true, numericality: { greater_than: 0 }
  validate :sufficient_stock_available

  # Callbacks
  before_validation :calculate_total_price
  before_validation :set_unit_price
  after_create :reduce_product_stock
  after_update :adjust_product_stock
  after_destroy :restore_product_stock

  # Methods
  def calculate_total_price
    self.total_price = quantity * unit_price if quantity && unit_price
  end

  private

  def set_unit_price
    self.unit_price = product.price if product && unit_price.nil?
  end

  def sufficient_stock_available
    return unless product && quantity.present?
    
    if new_record?
      # For new records, check if current stock is sufficient
      if product.stock_quantity < quantity
        errors.add(:quantity, "Insufficient stock. Available: #{product.stock_quantity}")
      end
    else
      # For updates, check if stock is sufficient considering the difference
      quantity_difference = quantity - quantity_was.to_i
      if quantity_difference > 0 && product.stock_quantity < quantity_difference
        errors.add(:quantity, "Insufficient stock. Available: #{product.stock_quantity}, Required: #{quantity_difference}")
      end
    end
  end

  def reduce_product_stock
    product.reduce_stock(quantity) if product
  end

  def adjust_product_stock
    return unless product && quantity_changed?
    
    old_quantity = quantity_was.to_i
    new_quantity = quantity.to_i
    difference = new_quantity - old_quantity
    
    if difference > 0
      # Quantity increased, reduce more stock
      product.reduce_stock(difference)
    elsif difference < 0
      # Quantity decreased, restore stock
      product.add_stock(difference.abs)
    end
  end

  def restore_product_stock
    product.add_stock(quantity) if product
  end
end
