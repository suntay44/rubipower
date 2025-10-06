class ExpenseRevenuesController < ApplicationController
  before_action :set_expense_revenue, only: [ :show, :edit, :update, :destroy, :delete_receipt, :delete_supporting_document, :approve_supervisor, :reject_supervisor, :approve_finance, :reject_finance ]
  before_action :set_current_user

  def index
    @pending_supervisor = ExpenseRevenue.pending_supervisor.order(created_at: :desc)
    @pending_finance = ExpenseRevenue.pending_finance.order(created_at: :desc)
    @approved_payment = ExpenseRevenue.approved_payment.order(created_at: :desc)
    @completed = ExpenseRevenue.completed.order(created_at: :desc)
  end

  def show
  end

  def new
    @expense_revenue = ExpenseRevenue.new
    @expense_revenue.expense_date = Date.current
    @expense_revenue.receipt_date = Date.current
  end

  def create
    @expense_revenue = ExpenseRevenue.new(expense_revenue_params)
    @expense_revenue.requester_user = @current_user

    if @expense_revenue.save
      redirect_to @expense_revenue, notice: "Expense/Revenue entry was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @expense_revenue.update(expense_revenue_params)
      redirect_to @expense_revenue, notice: "Expense/Revenue entry was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @expense_revenue.destroy
    redirect_to expense_revenues_path, notice: "Expense/Revenue entry was successfully deleted."
  end

  def delete_receipt
    attachment = @expense_revenue.receipts.find_by(blob_id: params[:attachment_id])

    if attachment
      attachment.purge
      head :ok
    else
      head :not_found
    end
  rescue => e
    head :internal_server_error
  end

  def delete_supporting_document
    attachment = @expense_revenue.supporting_documents.find_by(blob_id: params[:attachment_id])

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
    if @expense_revenue.update(supervisor_status: :approved)
      redirect_to @expense_revenue, notice: "Expense/Revenue entry approved by supervisor."
    else
      redirect_to @expense_revenue, alert: "Failed to approve entry."
    end
  end

  def reject_supervisor
    if @expense_revenue.update(supervisor_status: :rejected)
      redirect_to @expense_revenue, notice: "Expense/Revenue entry rejected by supervisor."
    else
      redirect_to @expense_revenue, alert: "Failed to reject entry."
    end
  end

  def approve_finance
    if @expense_revenue.update(finance_status: :finance_approved, verified_by: @current_user, verified_at: Time.current)
      redirect_to @expense_revenue, notice: "Expense/Revenue entry approved by finance."
    else
      redirect_to @expense_revenue, alert: "Failed to approve entry."
    end
  end

  def reject_finance
    if @expense_revenue.update(finance_status: :finance_rejected)
      redirect_to @expense_revenue, notice: "Expense/Revenue entry rejected by finance."
    else
      redirect_to @expense_revenue, alert: "Failed to reject entry."
    end
  end

  private

  def set_expense_revenue
    @expense_revenue = ExpenseRevenue.find(params[:id])
  end

  def set_current_user
    @current_user = User.find(session[:user_id]) if session[:user_id]
  end

  def expense_revenue_params
    params.require(:expense_revenue).permit(:expense_date, :vendor_name, :vendor_address, :vendor_tin,
                                           :purpose, :amount, :receipt_date, :po_number, :rfp_number,
                                           :bank_reference, :quantity, :unit_price, :category,
                                           :sales_order_number, :client_name, :supervisor_comments,
                                           :finance_comments, receipts: [], supporting_documents: [])
  end
end

