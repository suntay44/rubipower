class Sale < ApplicationRecord
  # Associations
  belongs_to :customer
  has_many :sale_items, dependent: :destroy
  has_many :products, through: :sale_items

  # Validations
  validates :sale_number, presence: true, uniqueness: true
  validates :total_amount, presence: true, numericality: { greater_than: 0 }
  validates :payment_status, inclusion: { in: %w[pending paid failed refunded] }
  validates :sale_date, presence: true

  # Scopes
  scope :pending, -> { where(payment_status: "pending") }
  scope :paid, -> { where(payment_status: "paid") }
  scope :failed, -> { where(payment_status: "failed") }
  scope :refunded, -> { where(payment_status: "refunded") }
  scope :recent, -> { where("sale_date >= ?", 30.days.ago) }
  scope :today, -> { where(sale_date: Date.current.all_day) }

  # Callbacks
  before_validation :generate_sale_number, on: :create
  after_create :update_customer_stats

  # Methods
  def total_items
    sale_items.sum(:quantity)
  end

  def completed?
    payment_status == "paid"
  end

  def pending?
    payment_status == "pending"
  end

  def failed?
    payment_status == "failed"
  end

  def refunded?
    payment_status == "refunded"
  end

  def payment_status_color
    case payment_status
    when "pending" then "yellow"
    when "paid" then "green"
    when "failed" then "red"
    when "refunded" then "orange"
    else "gray"
    end
  end

  private

  def generate_sale_number
    return if sale_number.present?

    loop do
      self.sale_number = "SALE-#{Time.current.strftime('%Y%m%d')}-#{rand(1000..9999)}"
      break unless Sale.exists?(sale_number: sale_number)
    end
  end

  def update_customer_stats
    customer.update_order_stats(total_amount)
  end
end
