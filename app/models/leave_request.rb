class LeaveRequest < ApplicationRecord
  belongs_to :user

  validates :leave_type, presence: true, inclusion: { in: %w[annual sick personal emergency] }
  validates :start_date, presence: true
  validates :end_date, presence: true
  validates :days, presence: true, numericality: { greater_than: 0 }
  validates :reason, presence: true
  validates :status, presence: true, inclusion: { in: %w[pending approved rejected] }

  scope :pending, -> { where(status: 'pending') }
  scope :approved, -> { where(status: 'approved') }
  scope :this_month, -> { where(start_date: Date.current.beginning_of_month..Date.current.end_of_month) }
  scope :by_type, ->(type) { where(leave_type: type) }

  def calculate_days
    return 0 unless start_date && end_date
    (end_date - start_date).to_i + 1
  end

  def update_days
    update(days: calculate_days) if start_date && end_date
  end

  def is_current?
    start_date <= Date.current && end_date >= Date.current
  end
end
