class PurchaseOrderController < ApplicationController
  def show
    @purchase_order = PurchaseOrder.includes(purchase_request: [ :requester_user, :items ], purchase_order_status_logs: :updated_by).find(params[:id])
    @purchase_request = @purchase_order.purchase_request
    @status_logs = @purchase_order.purchase_order_status_logs.ordered
  end

  def show_by_request
    @purchase_request = PurchaseRequest.includes(:requester_user, :items).find(params[:id])
    @purchase_order = @purchase_request.purchase_order

    if @purchase_order.nil?
      redirect_to purchase_request_detail_path(@purchase_request), alert: "No purchase order found for this request. Please create one first."
    else
      # Set the same variables as show action
      @status_logs = @purchase_order.purchase_order_status_logs.ordered
      # Render the same view as show action
      render :show
    end
  end

  def create
    @purchase_request = PurchaseRequest.find(params[:id])

    # Check if both approvals are present
    unless @purchase_request.all_approvals_complete?
      redirect_to purchase_request_detail_path(@purchase_request), alert: "Both Manager and Finance approvals are required to create a purchase order."
      return
    end

    # Check if purchase order already exists
    if @purchase_request.purchase_order.present?
      redirect_to purchase_order_path(@purchase_request.purchase_order), notice: "Purchase order already exists for this request."
      return
    end

    # Calculate total amount from items
    total_amount = @purchase_request.items.sum { |item| item.quantity * item.quoted_price }

    # Create the purchase order
    @purchase_order = @purchase_request.build_purchase_order(
      status: :draft,
      total_amount: total_amount
    )

    if @purchase_order.save
      redirect_to purchase_order_path(@purchase_order), notice: "Purchase order was successfully created."
    else
      redirect_to purchase_request_detail_path(@purchase_request), alert: "Failed to create purchase order: #{@purchase_order.errors.full_messages.join(', ')}"
    end
  end

  def update_status
    @purchase_order = PurchaseOrder.find(params[:id])
    new_status = params[:status]
    notes = params[:notes]

    # Handle goods received with delivery note and inspection report
    if new_status == "goods_received"
      @purchase_order.delivery_note = params[:delivery_note] if params[:delivery_note].present?
      @purchase_order.inspection_report.attach(params[:inspection_report]) if params[:inspection_report].present?
    end

    if @purchase_order.update(status: new_status)
      # Create status log entry
      begin
        status_log = @purchase_order.purchase_order_status_logs.create!(
          status: new_status,
          updated_by: current_user || User.first,
          notes: notes.present? ? notes : "Status changed to #{new_status.humanize}"
        )
        Rails.logger.info "Status log created successfully: #{status_log.id}"
      rescue => e
        Rails.logger.error "Failed to create status log: #{e.message}"
        Rails.logger.error e.backtrace.join("\n")
      end

      redirect_to purchase_order_path(@purchase_order), notice: "Purchase order status updated to #{new_status.humanize}."
    else
      redirect_to purchase_order_path(@purchase_order), alert: "Failed to update status: #{@purchase_order.errors.full_messages.join(', ')}"
    end
  end

  private

  def purchase_order_params
    params.require(:purchase_order).permit(:status, :total_amount)
  end
end
