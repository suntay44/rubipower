class ExpenseReportController < ApplicationController
  before_action :set_cash_advance_request, only: [ :show, :new, :create ]
  before_action :set_expense_report, only: [ :edit, :update, :delete_attachment ]
  before_action :set_current_user

  def show
    @expense_report = @cash_advance_request.expense_report
    if @expense_report.nil?
      redirect_to new_expense_report_path(@cash_advance_request), notice: "No expense report found. Please create one."
    end
  end

  def new
    @expense_report = @cash_advance_request.build_expense_report
  end

  def create
    @expense_report = @cash_advance_request.build_expense_report(expense_report_params)
    @expense_report.submitted_by = @current_user

    if @expense_report.save
      redirect_to expense_report_path(@cash_advance_request), notice: "Expense report was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @expense_report.update(expense_report_params)
      redirect_to expense_report_path(@expense_report.cash_advance_request), notice: "Expense report was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def delete_attachment
    attachment = @expense_report.receipts.find_by(blob_id: params[:attachment_id])

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

  def set_expense_report
    @expense_report = ExpenseReport.find(params[:id])
    @cash_advance_request = @expense_report.cash_advance_request
  end

  def set_current_user
    @current_user = User.find(session[:user_id]) if session[:user_id]
  end

  def expense_report_params
    params.require(:expense_report).permit(:explanation, :unused_cash, receipts: [])
  end
end

