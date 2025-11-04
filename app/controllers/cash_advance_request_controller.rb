class CashAdvanceRequestController < ApplicationController
  before_action :set_cash_advance_request, only: [ :show, :edit, :update, :approve_manager, :revise_manager, :reject_manager, :approve_finance, :reject_finance, :delete_attachment ]

  def index
    @cash_advance_requests = CashAdvanceRequest.includes(:requester_user).order(created_at: :desc)
    @pending_requests = @cash_advance_requests.pending_manager_approval
    @approved_requests = @cash_advance_requests.approved_by_manager
    @revised_requests = @cash_advance_requests.where(manager_status: "revised")
    @rejected_requests = @cash_advance_requests.where(manager_status: "rejected")
  end

  def show
  end

  def new
    @cash_advance_request = CashAdvanceRequest.new
    @departments = User.departments.keys.map(&:titleize)
    @users = User.all.order(:first_name, :last_name)
  end

  def create
    @cash_advance_request = CashAdvanceRequest.new(cash_advance_request_params)
    @cash_advance_request.requester_user = current_user
    @cash_advance_request.request_date = Date.current

    if @cash_advance_request.save
      redirect_to cash_advance_request_path(@cash_advance_request), notice: "Cash advance request was successfully created."
    else
      @departments = User.departments.keys.map(&:titleize)
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @departments = User.departments.keys.map(&:titleize)
    @users = User.all.order(:first_name, :last_name)
  end

  def update
    Rails.logger.info "UPDATE ACTION CALLED - Request ID: #{params[:id]}"
    params_hash = cash_advance_request_params
    # Filter out empty strings from supporting_documents to prevent clearing existing attachments
    if params_hash[:supporting_documents].present?
      params_hash[:supporting_documents] = params_hash[:supporting_documents].reject { |doc| doc.blank? || doc == "" }
    end

    # If no new documents are being uploaded, don't touch the existing ones
    if params_hash[:supporting_documents].empty?
      params_hash.delete(:supporting_documents)
    end

    if @cash_advance_request.update(params_hash)
      redirect_to cash_advance_request_path(@cash_advance_request), notice: "Cash advance request was successfully updated."
    else
      @departments = User.departments.keys.map(&:titleize)
      @users = User.all.order(:first_name, :last_name)
      render :edit, status: :unprocessable_entity
    end
  end

  def approve_manager
    if @cash_advance_request.update(manager_status: "approved")
      redirect_to cash_advance_request_path(@cash_advance_request), notice: "Cash advance request approved by manager."
    else
      redirect_to cash_advance_request_path(@cash_advance_request), alert: "Failed to approve request."
    end
  end

  def revise_manager
    if @cash_advance_request.update(manager_status: "revised")
      redirect_to cash_advance_request_path(@cash_advance_request), notice: "Cash advance request marked for revision by manager."
    else
      redirect_to cash_advance_request_path(@cash_advance_request), alert: "Failed to mark request for revision."
    end
  end

  def reject_manager
    if @cash_advance_request.update(manager_status: "rejected", manager_reject_notes: params[:manager_reject_notes])
      redirect_to cash_advance_request_path(@cash_advance_request), notice: "Cash advance request rejected by manager."
    else
      redirect_to cash_advance_request_path(@cash_advance_request), alert: "Failed to reject request."
    end
  end

  def approve_finance
    if @cash_advance_request.update(finance_department_status: "finance_approved", finance_department_documentation_notes: params[:finance_department_documentation_notes])
      redirect_to cash_advance_request_path(@cash_advance_request), notice: "Cash advance request approved by finance department."
    else
      redirect_to cash_advance_request_path(@cash_advance_request), alert: "Failed to approve request."
    end
  end

  def reject_finance
    if @cash_advance_request.update(finance_department_status: "finance_rejected", finance_department_documentation_notes: params[:finance_department_documentation_notes])
      redirect_to cash_advance_request_path(@cash_advance_request), notice: "Cash advance request rejected by finance department."
    else
      redirect_to cash_advance_request_path(@cash_advance_request), alert: "Failed to reject request."
    end
  end

  def delete_attachment
    attachment = @cash_advance_request.supporting_documents.find_by(blob_id: params[:attachment_id])

    if attachment
      attachment.purge
      head :ok
    else
      head :not_found
    end
  rescue => e
    head :internal_server_error
  end

  private

  def set_cash_advance_request
    @cash_advance_request = CashAdvanceRequest.find(params[:id])
  end

  def cash_advance_request_params
    params.require(:cash_advance_request).permit(
      :employee_name, :employee_id, :department, :sales_order_number, :client_name,
      :purpose_of_advance, :breakdown_of_expenses, :amount_requested, :required_date,
      :manager_reject_notes, :finance_department_documentation_notes,
      supporting_documents: []
    )
  end
end
