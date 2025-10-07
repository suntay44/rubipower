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

  private

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
