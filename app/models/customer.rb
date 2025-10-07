class Customer < ApplicationRecord
  # Associations
  has_many :orders, dependent: :destroy
  has_many :sales, dependent: :destroy

  # Validations
  validates :name, presence: true, length: { maximum: 255 }
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :phone, format: { with: /\A[\+]?[0-9\s\-\(\)]+\z/, message: "must be a valid phone number" }, allow_blank: true
  validates :customer_type, inclusion: { in: %w[individual business vip] }
  validates :status, inclusion: { in: %w[active inactive blocked] }
  validates :total_orders, numericality: { greater_than_or_equal_to: 0 }
  validates :total_spent, numericality: { greater_than_or_equal_to: 0 }

  # Scopes
  scope :active, -> { where(status: "active") }
  scope :by_type, ->(type) { where(customer_type: type) }
  scope :vip, -> { where(customer_type: "vip") }
  scope :recent_customers, -> { where("created_at >= ?", 30.days.ago) }

  # Callbacks
  before_save :normalize_email

  # Methods
  def full_name
    name
  end

  def average_order_value
    return 0 if total_orders == 0
    total_spent / total_orders
  end

  def update_order_stats(order_amount)
    increment(:total_orders)
    increment(:total_spent, order_amount)
    update(last_order_date: Time.current)
  end

  def vip?
    customer_type == "vip"
  end

  def active?
    status == "active"
  end

  private

  def normalize_email
    self.email = email.downcase.strip if email.present?
  end
end
