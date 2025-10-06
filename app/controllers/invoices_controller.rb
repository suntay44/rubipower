class InvoicesController < ApplicationController
  before_action :set_invoice, only: [ :show, :edit, :update, :destroy, :delete_attachment ]
  before_action :set_current_user

  def index
    @invoices = Invoice.all.order(created_at: :desc)
  end

  def show
  end

  def new
    @invoice = Invoice.new
    @invoice.invoice_date = Date.current
    @invoice.due_date = Date.current + 30.days
  end

  def create
    @invoice = Invoice.new(invoice_params)

    if @invoice.save
      redirect_to @invoice, notice: "Invoice was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @invoice.update(invoice_params)
      redirect_to @invoice, notice: "Invoice was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @invoice.destroy
    redirect_to invoices_path, notice: "Invoice was successfully deleted."
  end

  def delete_attachment
    attachment = @invoice.supporting_documents.find_by(blob_id: params[:attachment_id])

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

  def set_invoice
    @invoice = Invoice.find(params[:id])
  end

  def set_current_user
    @current_user = User.find(session[:user_id]) if session[:user_id]
  end

  def invoice_params
    params.require(:invoice).permit(:invoice_type, :company_name, :company_address, :company_contact,
                                   :client_name, :client_company, :client_address, :invoice_number,
                                   :invoice_date, :due_date, :description, :rates_and_quantities,
                                   :total_amount_due, :payment_instructions, supporting_documents: [])
  end
end

