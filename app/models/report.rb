class Report < ApplicationRecord
  validates :name, presence: true
  validates :report_type, presence: true
  validates :status, presence: true, inclusion: { in: %w[ready processing failed] }
  validates :generated_at, presence: true

  scope :recent, -> { order(generated_at: :desc) }
  scope :by_type, ->(type) { where(report_type: type) }
  scope :ready, -> { where(status: "ready") }
  scope :processing, -> { where(status: "processing") }

  def time_ago
    return "just now" if generated_at > 1.minute.ago
    return "#{((Time.current - generated_at) / 1.minute).round} minutes ago" if generated_at > 1.hour.ago
    return "#{((Time.current - generated_at) / 1.hour).round} hours ago" if generated_at > 1.day.ago
    return "#{((Time.current - generated_at) / 1.day).round} days ago" if generated_at > 1.week.ago
    return "#{((Time.current - generated_at) / 1.week).round} weeks ago" if generated_at > 1.month.ago
    "#{((Time.current - generated_at) / 1.month).round} months ago"
  end
end
