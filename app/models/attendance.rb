class Attendance < ApplicationRecord
  belongs_to :user

  validates :date, presence: true
  validates :clock_in, presence: true
  validates :status, presence: true, inclusion: { in: %w[present absent late on_leave] }

  scope :today, -> { where(date: Date.current) }
  scope :this_month, -> { where(date: Date.current.beginning_of_month..Date.current.end_of_month) }
  scope :by_status, ->(status) { where(status: status) }

  def calculate_hours_worked
    return 0 unless clock_in && clock_out
    
    ((clock_out - clock_in) / 1.hour).round(2)
  end

  def update_hours_worked
    update(hours_worked: calculate_hours_worked) if clock_out
  end

  def is_late?
    return false unless clock_in
    clock_in.hour > 9 || (clock_in.hour == 9 && clock_in.min > 0)
  end
end
