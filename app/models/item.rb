class Item < ApplicationRecord
  belongs_to :purchase_request

  validates :description, presence: true
  validates :quantity, presence: true, numericality: { greater_than: 0 }
  validates :cost, presence: true, numericality: { greater_than_or_equal_to: 0 }
end
