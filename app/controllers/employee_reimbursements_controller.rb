class EmployeeReimbursementsController < ApplicationController
  before_action :set_employee_reimbursement, only: [ :show, :edit, :update, :destroy, :approve_finance, :reject_finance ]

  def index
    @employee_reimbursements = EmployeeReimbursement.includes(:requester_user, :cash_advance_request).order(created_at: :desc)
    
    # Apply filters
    if params[:finance_status].present?
      @employee_reimbursements = @employee_reimbursements.where(finance_status: params[:finance_status])
    end
    
    if params[:search].present?
      search_term = "%#{params[:search]}%"
      @employee_reimbursements = @employee_reimbursements.where(
        "description ILIKE ? OR CAST(amount_to_reimburse AS TEXT) ILIKE ?",
        search_term, search_term
      ).or(
        EmployeeReimbursement.joins(:cash_advance_request).where(
          "cash_advance_requests.employee_name ILIKE ? OR cash_advance_requests.employee_id ILIKE ? OR CAST(cash_advance_requests.id AS TEXT) ILIKE ?",
          search_term, search_term, search_term
        )
      )
    end
  end

  def show
    @employee_reimbursement = EmployeeReimbursement.includes(:cash_advance_request, :requester_user).find(params[:id])
  end

  def new
    @employee_reimbursement = EmployeeReimbursement.new
    @cash_advance_requests = CashAdvanceRequest.where(finance_department_status: 'finance_approved').order(created_at: :desc).limit(100)
  end

  def create
    @employee_reimbursement = EmployeeReimbursement.new(employee_reimbursement_params)
    @employee_reimbursement.requester_user = current_user

    if @employee_reimbursement.save
      redirect_to @employee_reimbursement, notice: "Employee reimbursement request was successfully created."
    else
      @cash_advance_requests = CashAdvanceRequest.where(finance_department_status: 'finance_approved').order(created_at: :desc).limit(100)
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @cash_advance_requests = CashAdvanceRequest.where(finance_department_status: 'finance_approved').order(created_at: :desc).limit(100)
  end

  def update
    if @employee_reimbursement.update(employee_reimbursement_params)
      redirect_to @employee_reimbursement, notice: "Employee reimbursement request was successfully updated."
    else
      @cash_advance_requests = CashAdvanceRequest.where(finance_department_status: 'finance_approved').order(created_at: :desc).limit(100)
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @employee_reimbursement.destroy
    redirect_to employee_reimbursements_path, notice: "Employee reimbursement request was successfully deleted."
  end

  def approve_finance
    unless current_user.admin? || current_user.department_finance?
      redirect_to employee_reimbursement_path(@employee_reimbursement), alert: "Access denied. Admin or Finance privileges required."
      return
    end
    
    if @employee_reimbursement.update(finance_status: :finance_approved, finance_comments: params[:finance_comments])
      redirect_to @employee_reimbursement, notice: "Reimbursement request approved."
    else
      redirect_to @employee_reimbursement, alert: "Failed to approve request."
    end
  end

  def reject_finance
    unless current_user.admin? || current_user.department_finance?
      redirect_to employee_reimbursement_path(@employee_reimbursement), alert: "Access denied. Admin or Finance privileges required."
      return
    end
    
    if @employee_reimbursement.update(finance_status: :finance_rejected, finance_comments: params[:finance_comments])
      redirect_to @employee_reimbursement, notice: "Reimbursement request rejected."
    else
      redirect_to @employee_reimbursement, alert: "Failed to reject request."
    end
  end

  private

  def set_employee_reimbursement
    @employee_reimbursement = EmployeeReimbursement.find(params[:id])
  end

  def employee_reimbursement_params
    params.require(:employee_reimbursement).permit(:cash_advance_request_id, :description, :amount_to_reimburse,
                                                   :supervisor_comments, :finance_comments, :payment_method,
                                                   :payment_processed_date)
  end
end
