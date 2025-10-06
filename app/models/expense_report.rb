class ExpenseReport < ApplicationRecord
  belongs_to :cash_advance_request
  belongs_to :submitted_by, class_name: "User"
  has_many_attached :receipts

  validates :explanation, presence: true
  validates :unused_cash, numericality: { greater_than_or_equal_to: 0 }
end
