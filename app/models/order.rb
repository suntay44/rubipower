class Order < ApplicationRecord
  # Associations
  belongs_to :customer
  has_many :order_items, dependent: :destroy
  has_many :products, through: :order_items

  # Validations
  validates :order_number, presence: true, uniqueness: true
  validates :status, inclusion: { in: %w[pending processing shipped delivered cancelled] }
  validates :priority, inclusion: { in: %w[low medium high urgent] }
  validates :total_amount, presence: true, numericality: { greater_than: 0 }
  validates :order_date, presence: true
  validates :payment_status, inclusion: { in: %w[pending paid failed refunded] }

  # Scopes
  scope :pending, -> { where(status: "pending") }
  scope :processing, -> { where(status: "processing") }
  scope :shipped, -> { where(status: "shipped") }
  scope :delivered, -> { where(status: "delivered") }
  scope :cancelled, -> { where(status: "cancelled") }
  scope :high_priority, -> { where(priority: "high") }
  scope :recent, -> { where("order_date >= ?", 30.days.ago) }

  # Callbacks
  before_validation :generate_order_number, on: :create
  after_create :update_customer_stats

  # Methods
  def total_items
    order_items.sum(:quantity)
  end

  def can_be_cancelled?
    %w[pending processing].include?(status)
  end

  def can_be_shipped?
    status == "processing" && payment_status == "paid"
  end

  def can_be_delivered?
    status == "shipped"
  end

  def status_color
    case status
    when "pending" then "yellow"
    when "processing" then "blue"
    when "shipped" then "green"
    when "delivered" then "purple"
    when "cancelled" then "red"
    else "gray"
    end
  end

  def priority_color
    case priority
    when "low" then "green"
    when "medium" then "yellow"
    when "high" then "orange"
    when "urgent" then "red"
    else "gray"
    end
  end

  private

  def generate_order_number
    return if order_number.present?

    loop do
      self.order_number = "ORD-#{Time.current.strftime('%Y%m%d')}-#{rand(1000..9999)}"
      break unless Order.exists?(order_number: order_number)
    end
  end

  def update_customer_stats
    customer.update_order_stats(total_amount)
  end
end
