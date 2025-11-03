class Role < ApplicationRecord
  belongs_to :user

  AVAILABLE_ROLES = %w[admin finance manager supervisor procurement teammates].freeze

  validates :name, presence: true, inclusion: { in: AVAILABLE_ROLES }
  validates :user_id, presence: true
  validates :name, uniqueness: { scope: :user_id, message: "role already assigned to this user" }
end
