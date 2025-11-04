class Sale < ApplicationRecord
  # Associations
  belongs_to :customer, optional: true
  has_many :sale_items, dependent: :destroy
  has_many :products, through: :sale_items
  accepts_nested_attributes_for :sale_items, allow_destroy: true

  # Validations
  validates :sale_number, presence: true, uniqueness: true
  validates :total_amount, presence: true, numericality: { greater_than: 0 }
  validates :payment_status, inclusion: { in: %w[pending paid failed refunded] }
  validates :sale_date, presence: true
  validates :project_name, uniqueness: { scope: :project_year }, allow_blank: true
  validates :client_name, presence: true
  validates :description, presence: true

  # Scopes
  scope :pending, -> { where(payment_status: "pending") }
  scope :paid, -> { where(payment_status: "paid") }
  scope :failed, -> { where(payment_status: "failed") }
  scope :refunded, -> { where(payment_status: "refunded") }
  scope :recent, -> { where("sale_date >= ?", 30.days.ago) }
  scope :today, -> { where(sale_date: Date.current.all_day) }

  # Callbacks
  before_validation :generate_sale_number, on: :create
  before_validation :generate_project_name, on: :create
  before_validation :set_project_year, on: :create
  before_validation :calculate_total_amount, if: -> { sale_items.present? }
  after_create :update_customer_stats
  before_destroy :restore_all_stock

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

  def generate_project_name
    return if project_name.present?
    
    current_year = Date.current.year
    self.project_year = current_year
    
    # Find the highest project number for this year
    last_project = Sale.where(project_year: current_year)
                      .where.not(project_name: nil)
                      .order(project_name: :desc)
                      .first
    
    if last_project && last_project.project_name.present?
      # Extract the incremental number (remove year prefix)
      # Format: "20251" -> extract "1"
      year_prefix = current_year.to_s
      if last_project.project_name.start_with?(year_prefix)
        incremental_str = last_project.project_name[year_prefix.length..-1]
        next_number = incremental_str.to_i + 1
      else
        next_number = 1
      end
    else
      next_number = 1
    end
    
    self.project_name = "#{current_year}#{next_number}"
  end

  def set_project_year
    self.project_year = Date.current.year if project_year.nil?
  end

  def calculate_total_amount
    self.total_amount = sale_items.sum(&:total_price) if sale_items.any?
  end

  def update_customer_stats
    customer&.update_order_stats(total_amount)
  end

  def restore_all_stock
    sale_items.each do |item|
      item.product.add_stock(item.quantity) if item.product
    end
  end
end
