class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # Associations
  has_many :roles, dependent: :destroy

  # Validations
  validates :first_name, presence: true, length: { minimum: 2, maximum: 50 }
  validates :last_name, presence: true, length: { minimum: 2, maximum: 50 }
  validates :phone_number, presence: true, format: { with: /\A\+?[\d\s\-\(\)]+\z/, message: "must be a valid phone number" }
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }

  # Instance methods
  def full_name
    "#{first_name} #{last_name}"
  end

  # Role checking methods
  def admin?
    roles.exists?(name: "admin")
  end

  def staff?
    roles.exists?(name: "staff")
  end

  def user?
    roles.exists?(name: "user")
  end

  def approver?
    roles.exists?(name: "approver")
  end

  def has_role?(role_name)
    roles.exists?(name: role_name)
  end

  def role_names
    roles.pluck(:name)
  end

  # Pundit authorization helper methods
  def can_manage_users?
    admin? || staff?
  end

  def can_delete_content?
    admin?
  end

  def can_approve?
    admin? || approver?
  end

  # Role management methods
  def add_role(role_name)
    return if has_role?(role_name)
    roles.create!(name: role_name)
  end

  def remove_role(role_name)
    roles.where(name: role_name).destroy_all
  end

  def set_roles(role_names)
    # Remove all existing roles
    roles.destroy_all
    # Add new roles
    role_names.each { |role_name| add_role(role_name) }
  end
end
