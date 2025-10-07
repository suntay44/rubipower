class Payslip < ApplicationRecord
  belongs_to :user

  validates :pay_period_start, presence: true
  validates :pay_period_end, presence: true
  validates :gross_pay, presence: true, numericality: { greater_than: 0 }
  validates :deductions, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :net_pay, presence: true, numericality: { greater_than: 0 }
  validates :status, presence: true, inclusion: { in: %w[generated paid] }

  scope :this_month, -> { where(pay_period_start: Date.current.beginning_of_month..Date.current.end_of_month) }
  scope :by_status, ->(status) { where(status: status) }

  def pay_period
    "#{pay_period_start.strftime('%B %d')} - #{pay_period_end.strftime('%B %d, %Y')}"
  end

  def calculate_net_pay
    gross_pay - deductions
  end

  def update_net_pay
    update(net_pay: calculate_net_pay)
  end
end
