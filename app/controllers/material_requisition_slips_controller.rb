class MaterialRequisitionSlipsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_requisition, only: [:show, :edit, :update, :destroy, :approve_supervisor, :reject_supervisor, :approve_procurement, :reject_procurement, :approve_engineering, :reject_engineering, :approve_admin, :reject_admin, :create_purchase_request, :purge_proposal]

  def index
    @requisitions = MaterialRequisitionSlip.includes(:requester_user, :items => :vendor)
                                           .recent
                                           .page(params[:page])
                                           .per(20)
    
    # Filters
    if params[:status].present?
      case params[:status]
      when 'pending_supervisor'
        @requisitions = @requisitions.where(supervisor_approved: false)
      when 'pending_procurement'
        @requisitions = @requisitions.where(supervisor_approved: true, procurement_approved: false)
      when 'pending_engineering'
        @requisitions = @requisitions.where(procurement_approved: true, engineering_approved: false)
      when 'pending_admin'
        @requisitions = @requisitions.where(engineering_approved: true, admin_approved: false)
      when 'all_approved'
        @requisitions = @requisitions.where(supervisor_approved: true, procurement_approved: true, engineering_approved: true, admin_approved: true)
      end
    end
    @requisitions = @requisitions.by_department(params[:department]) if params[:department].present?
  end

  def show
  end

  def new
    @requisition = MaterialRequisitionSlip.new
    @requisition.items.build
    @materials = Material.active.includes(:vendor).by_name
    @departments = User.departments.keys.map(&:titleize)
  end

  def create
    @requisition = MaterialRequisitionSlip.new(requisition_params)
    @requisition.requester_user = current_user

    if @requisition.save
      # Create Items from materials selected
      if params[:material_requisition_slip][:items_attributes].present?
        params[:material_requisition_slip][:items_attributes].each do |key, item_params|
          next if item_params[:_destroy] == "1" || item_params[:material_id].blank?
          
          material = Material.find(item_params[:material_id])
          @requisition.items.create!(
            name: material.name,
            description: item_params[:description].presence || material.description || "",
            quantity: item_params[:quantity].to_i,
            quoted_price: item_params[:quoted_price].to_f,
            vendor: material.vendor,
            material_requisition_slip_id: @requisition.id
          )
        end
      end
      
      redirect_to material_requisition_slip_path(@requisition), notice: "Material Requisition Slip was successfully created."
    else
      @materials = Material.active.includes(:vendor).by_name
      @departments = User.departments.keys.map(&:titleize)
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @materials = Material.active.includes(:vendor).by_name
    @departments = User.departments.keys.map(&:titleize)
  end

  def update
    # Only allow editing if not yet supervisor approved
    if @requisition.supervisor_approved?
      redirect_to material_requisition_slip_path(@requisition), alert: "Cannot edit requisition after supervisor approval."
      return
    end

    if @requisition.update(requisition_params)
      # Handle vendor proposal attachments (for procurement role)
      if params[:material_requisition_slip][:vendor_proposal_1].present?
        @requisition.vendor_proposal_1.attach(params[:material_requisition_slip][:vendor_proposal_1])
      end
      if params[:material_requisition_slip][:vendor_proposal_2].present?
        @requisition.vendor_proposal_2.attach(params[:material_requisition_slip][:vendor_proposal_2])
      end
      if params[:material_requisition_slip][:vendor_proposal_3].present?
        @requisition.vendor_proposal_3.attach(params[:material_requisition_slip][:vendor_proposal_3])
      end

      # Update items if provided (only exclusive items, not those used in Purchase Requests)
      if params[:material_requisition_slip][:items_attributes].present?
        # Only destroy exclusive items (items not used in Purchase Requests)
        @requisition.items_exclusive.destroy_all
        params[:material_requisition_slip][:items_attributes].each do |key, item_params|
          next if item_params[:_destroy] == "1" || item_params[:material_id].blank?
          
          material = Material.find(item_params[:material_id])
          @requisition.items.create!(
            name: material.name,
            description: item_params[:description].presence || material.description || "",
            quantity: item_params[:quantity].to_i,
            quoted_price: item_params[:quoted_price].to_f,
            vendor: material.vendor,
            material_requisition_slip_id: @requisition.id
          )
        end
      end
      
      redirect_to material_requisition_slip_path(@requisition), notice: "Material Requisition Slip was successfully updated."
    else
      @materials = Material.active.includes(:vendor).by_name
      @departments = User.departments.keys.map(&:titleize)
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @requisition.supervisor_approved?
      redirect_to material_requisition_slips_path, alert: "Cannot delete requisition after supervisor approval."
      return
    end
    @requisition.destroy
    redirect_to material_requisition_slips_path, notice: "Material Requisition Slip was successfully deleted."
  end

  # Multi-step approval actions
  def approve_supervisor
    if @requisition.can_be_approved_by?(current_user) && @requisition.current_approval_step == :supervisor
      @requisition.update(
        supervisor_approved: true,
        supervisor_approved_by: current_user.id,
        supervisor_approved_at: Time.current
      )
      redirect_to material_requisition_slip_path(@requisition), notice: "Supervisor approval granted."
    else
      redirect_to material_requisition_slip_path(@requisition), alert: "You cannot approve this requisition at this stage."
    end
  end

  def reject_supervisor
    if @requisition.can_be_approved_by?(current_user) && @requisition.current_approval_step == :supervisor
      @requisition.update(
        supervisor_approved: false,
        supervisor_approved_by: current_user.id,
        supervisor_approved_at: Time.current
      )
      redirect_to material_requisition_slip_path(@requisition), notice: "Requisition returned for revision."
    else
      redirect_to material_requisition_slip_path(@requisition), alert: "You cannot reject this requisition at this stage."
    end
  end

  def approve_procurement
    if @requisition.can_be_approved_by?(current_user) && @requisition.current_approval_step == :procurement && @requisition.supervisor_approved?
      @requisition.update(
        procurement_approved: true,
        procurement_approved_by: current_user.id,
        procurement_approved_at: Time.current
      )
      redirect_to material_requisition_slip_path(@requisition), notice: "Procurement approval granted."
    else
      redirect_to material_requisition_slip_path(@requisition), alert: "You cannot approve this requisition at this stage."
    end
  end

  def reject_procurement
    if @requisition.can_be_approved_by?(current_user) && @requisition.current_approval_step == :procurement
      @requisition.update(
        procurement_approved: false,
        procurement_approved_by: current_user.id,
        procurement_approved_at: Time.current
      )
      redirect_to material_requisition_slip_path(@requisition), notice: "Requisition returned for revision."
    else
      redirect_to material_requisition_slip_path(@requisition), alert: "You cannot reject this requisition at this stage."
    end
  end

  def approve_engineering
    if @requisition.can_be_approved_by?(current_user) && @requisition.current_approval_step == :engineering && @requisition.procurement_approved?
      @requisition.update(
        engineering_approved: true,
        engineering_approved_by: current_user.id,
        engineering_approved_at: Time.current
      )
      redirect_to material_requisition_slip_path(@requisition), notice: "Engineering approval granted."
    else
      redirect_to material_requisition_slip_path(@requisition), alert: "You cannot approve this requisition at this stage."
    end
  end

  def reject_engineering
    if @requisition.can_be_approved_by?(current_user) && @requisition.current_approval_step == :engineering
      @requisition.update(
        engineering_approved: false,
        engineering_approved_by: current_user.id,
        engineering_approved_at: Time.current
      )
      redirect_to material_requisition_slip_path(@requisition), notice: "Requisition returned for revision."
    else
      redirect_to material_requisition_slip_path(@requisition), alert: "You cannot reject this requisition at this stage."
    end
  end

  def approve_admin
    if @requisition.can_be_approved_by?(current_user) && @requisition.current_approval_step == :admin && @requisition.engineering_approved?
      @requisition.update(
        admin_approved: true,
        admin_approved_by: current_user.id,
        admin_approved_at: Time.current
      )
      redirect_to material_requisition_slip_path(@requisition), notice: "Admin approval granted."
    else
      redirect_to material_requisition_slip_path(@requisition), alert: "You cannot approve this requisition at this stage."
    end
  end

  def reject_admin
    if @requisition.can_be_approved_by?(current_user) && @requisition.current_approval_step == :admin
      @requisition.update(
        admin_approved: false,
        admin_approved_by: current_user.id,
        admin_approved_at: Time.current
      )
      redirect_to material_requisition_slip_path(@requisition), notice: "Requisition returned for revision."
    else
      redirect_to material_requisition_slip_path(@requisition), alert: "You cannot reject this requisition at this stage."
    end
  end

  def create_purchase_request
    unless @requisition.all_approvals_complete?
      redirect_to material_requisition_slip_path(@requisition), alert: "All approvals must be completed before creating a Purchase Request."
      return
    end

    # Store MRS data in session to pre-fill Purchase Request form
    session[:mrs_data] = {
      mrs_id: @requisition.id,
      request_date: @requisition.request_date,
      priority_level: @requisition.priority_level,
      reason_for_purchase: @requisition.purpose,
      department: @requisition.department,
      items: @requisition.items_exclusive.any? ? @requisition.items_exclusive.map do |item|
        {
          name: item.name,
          description: item.description,
          quantity: item.quantity,
          quoted_price: item.quoted_price,
          vendor_id: item.vendor_id
        }
      end : []
    }

    # Redirect with mrs_id as query parameter
    redirect_to new_purchase_request_path(mrs_id: @requisition.id), notice: "Material Requisition Slip data loaded. Please complete the Purchase Request form."
  end

  def purge_proposal
    if params[:proposal_id].present?
      # Find attachment by signed_id
      proposal = @requisition.proposals.find_by_signed_id(params[:proposal_id])
      if proposal
        proposal.purge
        redirect_to edit_material_requisition_slip_path(@requisition), notice: "Proposal removed successfully."
      else
        redirect_to edit_material_requisition_slip_path(@requisition), alert: "Proposal not found."
      end
    else
      redirect_to edit_material_requisition_slip_path(@requisition), alert: "Invalid request."
    end
  end

  private

  def set_requisition
    @requisition = MaterialRequisitionSlip.find(params[:id])
  end

  def requisition_params
    params.require(:material_requisition_slip).permit(
      :request_date,
      :department,
      :purpose,
      :priority_level,
      :lead_time,
      vendor_proposal_1: [],
      vendor_proposal_2: [],
      vendor_proposal_3: [],
      proposals: []
    )
  end
end
