class Role < ApplicationRecord
  belongs_to :user

  validates :name, presence: true, inclusion: { in: %w[admin user staff approver] }
  validates :user_id, presence: true
  validates :name, uniqueness: { scope: :user_id, message: "role already assigned to this user" }

  AVAILABLE_ROLES = %w[admin user staff approver].freeze
end
