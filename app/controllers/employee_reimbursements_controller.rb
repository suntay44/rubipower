class EmployeeReimbursementsController < ApplicationController
  before_action :set_employee_reimbursement, only: [ :show, :edit, :update, :destroy, :delete_receipt, :delete_proof, :delete_itinerary, :approve_supervisor, :revise_supervisor, :reject_supervisor, :approve_finance, :reject_finance ]
  before_action :set_current_user

  def index
    @pending_supervisor = EmployeeReimbursement.pending_supervisor.order(created_at: :desc)
    @pending_finance = EmployeeReimbursement.pending_finance.order(created_at: :desc)
    @approved_payment = EmployeeReimbursement.approved_payment.order(created_at: :desc)
    @completed = EmployeeReimbursement.completed.order(created_at: :desc)
  end

  def show
  end

  def new
    @employee_reimbursement = EmployeeReimbursement.new
    @employee_reimbursement.expense_date = Date.current
    @users = User.all.order(:first_name, :last_name)
  end

  def create
    @employee_reimbursement = EmployeeReimbursement.new(employee_reimbursement_params)
    @employee_reimbursement.requester_user = @current_user

    if @employee_reimbursement.save
      redirect_to @employee_reimbursement, notice: "Employee reimbursement request was successfully created."
    else
      @users = User.all.order(:first_name, :last_name)
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @users = User.all.order(:first_name, :last_name)
  end

  def update
    if @employee_reimbursement.update(employee_reimbursement_params)
      redirect_to @employee_reimbursement, notice: "Employee reimbursement request was successfully updated."
    else
      @users = User.all.order(:first_name, :last_name)
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @employee_reimbursement.destroy
    redirect_to employee_reimbursements_path, notice: "Employee reimbursement request was successfully deleted."
  end

  def delete_receipt
    attachment = @employee_reimbursement.receipts.find_by(blob_id: params[:attachment_id])

    if attachment
      attachment.purge
      head :ok
    else
      head :not_found
    end
  rescue => e
    head :internal_server_error
  end

  def delete_proof
    attachment = @employee_reimbursement.proof_of_payment.find_by(blob_id: params[:attachment_id])

    if attachment
      attachment.purge
      head :ok
    else
      head :not_found
    end
  rescue => e
    head :internal_server_error
  end

  def delete_itinerary
    attachment = @employee_reimbursement.travel_itinerary.find_by(blob_id: params[:attachment_id])

    if attachment
      attachment.purge
      head :ok
    else
      head :not_found
    end
  rescue => e
    head :internal_server_error
  end

  def approve_supervisor
    if @employee_reimbursement.update(supervisor_status: :approved)
      redirect_to @employee_reimbursement, notice: "Reimbursement request approved by supervisor."
    else
      redirect_to @employee_reimbursement, alert: "Failed to approve request."
    end
  end

  def revise_supervisor
    if @employee_reimbursement.update(supervisor_status: :revised)
      redirect_to @employee_reimbursement, notice: "Reimbursement request marked for revision."
    else
      redirect_to @employee_reimbursement, alert: "Failed to mark for revision."
    end
  end

  def reject_supervisor
    if @employee_reimbursement.update(supervisor_status: :rejected)
      redirect_to @employee_reimbursement, notice: "Reimbursement request rejected by supervisor."
    else
      redirect_to @employee_reimbursement, alert: "Failed to reject request."
    end
  end

  def approve_finance
    if @employee_reimbursement.update(finance_status: :finance_approved)
      redirect_to @employee_reimbursement, notice: "Reimbursement request approved by finance."
    else
      redirect_to @employee_reimbursement, alert: "Failed to approve request."
    end
  end

  def reject_finance
    if @employee_reimbursement.update(finance_status: :finance_rejected)
      redirect_to @employee_reimbursement, notice: "Reimbursement request rejected by finance."
    else
      redirect_to @employee_reimbursement, alert: "Failed to reject request."
    end
  end

  private

  def set_employee_reimbursement
    @employee_reimbursement = EmployeeReimbursement.find(params[:id])
  end

  def set_current_user
    @current_user = User.find(session[:user_id]) if session[:user_id]
  end

  def employee_reimbursement_params
    params.require(:employee_reimbursement).permit(:employee_name, :employee_id, :expense_type, :expense_purpose,
                                                   :amount_claimed, :expense_date, :sales_order_number, :client_name,
                                                   :supervisor_comments, :finance_comments, :payment_method,
                                                   :payment_processed_date, receipts: [], proof_of_payment: [], travel_itinerary: [])
  end
end
