class Product < ApplicationRecord
  # Associations
  has_many :order_items, dependent: :destroy
  has_many :orders, through: :order_items
  has_many :sale_items, dependent: :destroy
  has_many :sales, through: :sale_items

  # Validations
  validates :name, presence: true, length: { maximum: 255 }
  validates :sku, presence: true, uniqueness: true, length: { maximum: 50 }
  validates :price, presence: true, numericality: { greater_than: 0 }
  validates :stock_quantity, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :reorder_level, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :status, inclusion: { in: %w[active inactive discontinued] }
  validates :category, presence: true

  # Scopes
  scope :active, -> { where(status: "active") }
  scope :low_stock, -> { where("stock_quantity <= reorder_level") }
  scope :by_category, ->(category) { where(category: category) }

  # Callbacks
  before_save :normalize_sku

  # Methods
  def low_stock?
    stock_quantity <= reorder_level
  end

  def out_of_stock?
    stock_quantity == 0
  end

  def available?
    status == "active" && stock_quantity > 0
  end

  def reduce_stock(quantity)
    return false if stock_quantity < quantity

    update(stock_quantity: stock_quantity - quantity)
  end

  def add_stock(quantity)
    update(stock_quantity: stock_quantity + quantity)
  end

  private

  def normalize_sku
    self.sku = sku.upcase.strip if sku.present?
  end
end
