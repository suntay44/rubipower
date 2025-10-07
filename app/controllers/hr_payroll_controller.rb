class HrPayrollController < ApplicationController
  before_action :authenticate_user!

  def index
    # Main HR & Payroll dashboard
    @total_employees = User.employees.count
    @active_today = User.active_employees.joins(:attendances)
                        .where(attendances: { date: Date.current, status: "present" }).count
    @pending_leaves = LeaveRequest.pending.count
    @payslips_generated = Payslip.this_month.count

    @recent_activities = get_recent_activities
  end

  def time_tracking
    @current_attendance = current_user.current_attendance_today
    @recent_attendances = current_user.attendances.order(date: :desc).limit(10)
  end

  def payslips
    @payslips = current_user.payslips.order(pay_period_end: :desc)
  end

  def leaves
    @leave_requests = current_user.leave_requests.order(created_at: :desc)
    @leave_balance = get_leave_balance
  end

  def attendance
    @today_attendance = Attendance.today.includes(:user)
    @attendance_summary = get_attendance_summary
  end

  def employee_records
    @employees = User.employees.includes(:attendances, :leave_requests, :payslips)
    @departments = User.employees.distinct.pluck(:department).compact
  end

  def payroll_reports
    @total_payroll = Payslip.this_month.sum(:net_pay)
    @employees_paid = Payslip.this_month.distinct.count(:user_id)
    @average_salary = Payslip.this_month.average(:net_pay)
    @recent_reports = Payslip.includes(:user).order(created_at: :desc).limit(5)
  end

  def user_management
    authorize_user_management!
    @users = User.includes(:roles).order(:first_name, :last_name)
    @roles = Role::AVAILABLE_ROLES
    @total_users = @users.count
    @active_users = @users.where(status: "active").count
    @inactive_users = @users.where(status: "inactive").count
  end

  def new_user
    authorize_user_management!
    @user = User.new
    @roles = Role::AVAILABLE_ROLES
  end

  def create_user
    authorize_user_management!
    @user = User.new(user_params)

    if @user.save
      # Assign roles if provided
      if params[:user][:role_names].present?
        @user.set_roles(params[:user][:role_names].reject(&:blank?))
      end

      redirect_to hr_payroll_user_management_path, notice: "User was successfully created."
    else
      @roles = Role::AVAILABLE_ROLES
      render :new_user, status: :unprocessable_entity
    end
  end

  def edit_user
    authorize_user_management!
    @user = User.find(params[:id])
    @roles = Role::AVAILABLE_ROLES
  end

  def update_user
    authorize_user_management!
    @user = User.find(params[:id])

    # Handle password fields - remove them if blank to keep current password
    update_params = user_params
    if update_params[:password].blank?
      update_params.delete(:password)
      update_params.delete(:password_confirmation)
    end

    if @user.update(update_params)
      # Update roles if provided
      if params[:user][:role_names].present?
        @user.set_roles(params[:user][:role_names].reject(&:blank?))
      end

      redirect_to hr_payroll_user_management_path, notice: "User was successfully updated."
    else
      @roles = Role::AVAILABLE_ROLES
      render :edit_user, status: :unprocessable_entity
    end
  end

  def destroy_user
    authorize_user_management!
    @user = User.find(params[:id])

    # Prevent admin from deleting themselves
    if @user == current_user
      redirect_to hr_payroll_user_management_path, alert: "You cannot delete your own account."
      return
    end

    @user.destroy
    redirect_to hr_payroll_user_management_path, notice: "User was successfully deleted."
  end

  private

  def authorize_user_management!
    unless current_user&.admin?
      redirect_to hr_payroll_path, alert: "Access denied. Admin privileges required."
    end
  end

  def user_params
    params.require(:user).permit(:first_name, :last_name, :email, :phone_number, :position, :department, :hire_date, :status, :password, :password_confirmation)
  end

  def get_recent_activities
    activities = []

    # Recent clock-ins
    recent_clock_ins = Attendance.today.where.not(clock_in: nil)
                                 .includes(:user)
                                 .order(clock_in: :desc)
                                 .limit(3)

    recent_clock_ins.each do |attendance|
      activities << {
        type: "clock_in",
        message: "#{attendance.user.full_name} clocked in",
        time: attendance.clock_in,
        icon: "green"
      }
    end

    # Recent leave applications
    recent_leaves = LeaveRequest.includes(:user)
                               .order(created_at: :desc)
                               .limit(2)

    recent_leaves.each do |leave|
      activities << {
        type: "leave",
        message: "#{leave.user.full_name} applied for #{leave.leave_type} leave",
        time: leave.created_at,
        icon: "blue"
      }
    end

    # Recent payslips
    recent_payslips = Payslip.includes(:user)
                            .order(created_at: :desc)
                            .limit(1)

    recent_payslips.each do |payslip|
      activities << {
        type: "payslip",
        message: "Payslips generated for #{payslip.pay_period_start.strftime('%B %Y')}",
        time: payslip.created_at,
        icon: "purple"
      }
    end

    activities.sort_by { |a| a[:time] }.reverse.first(3)
  end

  def get_leave_balance
    {
      annual: 15 - current_user.leave_requests.where(leave_type: "annual", status: "approved").sum(:days),
      sick: 10 - current_user.leave_requests.where(leave_type: "sick", status: "approved").sum(:days),
      personal: 5 - current_user.leave_requests.where(leave_type: "personal", status: "approved").sum(:days)
    }
  end

  def get_attendance_summary
    today = Date.current
    {
      present: Attendance.today.where(status: "present").count,
      absent: User.active_employees.count - Attendance.today.where(status: "present").count,
      late: Attendance.today.where(status: "late").count,
      on_leave: User.where(status: "on_leave").count
    }
  end
end
