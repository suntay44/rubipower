class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable,
         :recoverable, :rememberable, :validatable

  # Enums
  enum :department, {
    finance: 0,
    engineering: 1,
    operations: 2,
    general: 3
  }, prefix: true

  # Associations
  has_many :roles, dependent: :destroy
  has_many :purchase_requests, foreign_key: "requester_user_id", dependent: :destroy
  has_many :attendances, dependent: :destroy
  has_many :leave_requests, dependent: :destroy
  has_many :payslips, dependent: :destroy

  # Validations
  validates :first_name, presence: true, length: { minimum: 2, maximum: 50 }
  validates :last_name, presence: true, length: { minimum: 2, maximum: 50 }
  validates :phone_number, presence: true, format: { with: /\A\+?[\d\s\-\(\)]+\z/, message: "must be a valid phone number" }
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :position, presence: true, if: -> { department.present? }
  validates :department, presence: true, if: -> { position.present? }
  validates :hire_date, presence: true, if: -> { position.present? }
  validates :status, inclusion: { in: %w[active inactive on_leave] }, allow_blank: true

  # Instance methods
  def full_name
    "#{first_name} #{last_name}"
  end

  def employee_id
    id.to_s.rjust(5, "0")
  end

  # Role checking methods
  def admin?
    roles.exists?(name: "admin")
  end

  def finance?
    roles.exists?(name: "finance")
  end

  def manager?
    roles.exists?(name: "manager")
  end

  def supervisor?
    roles.exists?(name: "supervisor")
  end

  def procurement?
    roles.exists?(name: "procurement")
  end

  def teammates?
    roles.exists?(name: "teammates")
  end

  def has_role?(role_name)
    roles.exists?(name: role_name)
  end

  def role_names
    roles.pluck(:name)
  end

  # Pundit authorization helper methods
  def can_manage_users?
    admin? || manager?
  end

  def can_delete_content?
    admin?
  end

  def can_approve?
    admin? || manager? || supervisor?
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

  # HR-related methods
  def current_attendance_today
    attendances.where(date: Date.current).first
  end

  def is_clocked_in?
    current_attendance_today&.clock_out.nil?
  end

  def is_employee?
    position.present? && department.present?
  end

  def active_leave_requests
    leave_requests.where(status: "approved").where("start_date <= ? AND end_date >= ?", Date.current, Date.current)
  end

  def on_leave?
    active_leave_requests.exists?
  end

  def latest_payslip
    payslips.order(pay_period_end: :desc).first
  end

  # Scopes for HR
  scope :employees, -> { where.not(position: nil, department: nil) }
  scope :active_employees, -> { employees.where(status: "active") }
  scope :by_department, ->(dept) { where(department: departments[dept.to_sym] || dept) }
end
