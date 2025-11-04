require "prawn"
require "prawn/table"

class CashAdvanceRequestPdf < Prawn::Document
  def initialize(cash_advance_request)
    super(top_margin: 70, bottom_margin: 70)
    @cash_advance_request = cash_advance_request
    generate_pdf
  end

  private

  def generate_pdf
    header
    move_down 20
    employee_information
    move_down 15
    project_information
    move_down 15
    request_details
    move_down 15
    breakdown_of_expenses
    move_down 15
    status_section
    move_down 15
    notes_section
    footer
  end

  def header
    text "Cash Advance Request", size: 24, style: :bold, align: :center
    text "Request ##{@cash_advance_request.id}", size: 16, align: :center
    move_down 10
    stroke_horizontal_rule
  end

  def employee_information
    text "Employee Information", size: 16, style: :bold
    move_down 5
    stroke_horizontal_rule
    move_down 10
    
    data = [
      ["Employee Name:", safe_text(@cash_advance_request.employee_name) || "N/A"],
      ["Employee ID:", safe_text(@cash_advance_request.employee_id) || "N/A"],
      ["Department:", safe_text(@cash_advance_request.department) || "N/A"]
    ]
    
    table(data, width: 500, cell_style: { padding: 5, border_width: 0 }) do
      columns(0).font_style = :bold
      columns(0).width = 150
    end
  end

  def project_information
    text "Project Information", size: 16, style: :bold
    move_down 5
    stroke_horizontal_rule
    move_down 10
    
    data = [
      ["Sales Order Number:", safe_text(@cash_advance_request.sales_order_number) || "N/A"],
      ["Client Name:", safe_text(@cash_advance_request.client_name) || "N/A"]
    ]
    
    if @cash_advance_request.sale.present?
      data << ["Sale Total:", "PHP #{number_with_precision(@cash_advance_request.sale.total_amount, precision: 2)}"]
    end
    
    if @cash_advance_request.description.present?
      data << ["Description:", safe_text(@cash_advance_request.description)]
    end
    
    table(data, width: 500, cell_style: { padding: 5, border_width: 0 }) do
      columns(0).font_style = :bold
      columns(0).width = 150
    end
  end

  def request_details
    text "Request Details", size: 16, style: :bold
    move_down 5
    stroke_horizontal_rule
    move_down 10
    
    data = [
      ["Purpose of Advance:", safe_text(@cash_advance_request.purpose_of_advance) || "N/A"],
      ["Amount Requested:", "PHP #{number_with_precision(@cash_advance_request.amount_requested || 0, precision: 2)}"],
      ["Required Date:", @cash_advance_request.required_date ? @cash_advance_request.required_date.strftime("%B %d, %Y") : "N/A"],
      ["Request Date:", @cash_advance_request.request_date ? @cash_advance_request.request_date.strftime("%B %d, %Y") : "N/A"]
    ]
    
    table(data, width: 500, cell_style: { padding: 5, border_width: 0 }) do
      columns(0).font_style = :bold
      columns(0).width = 150
      row(1).columns(1).font_style = :bold
    end
  end

  def breakdown_of_expenses
    text "Breakdown of Expenses", size: 16, style: :bold
    move_down 5
    stroke_horizontal_rule
    move_down 10
    
    begin
      expense_items = JSON.parse(@cash_advance_request.breakdown_of_expenses || '[]')
    rescue JSON::ParserError
      expense_items = []
    end
    
    if expense_items.is_a?(Array) && expense_items.any?
      table_data = [["Name", "Amount Requested"]]
      
      expense_items.each do |item|
        name = safe_text(item['name'] || item[:name]) || 'N/A'
        amount = item['amount'] || item[:amount] || 0
        table_data << [name, "PHP #{number_with_precision(amount.to_f, precision: 2)}"]
      end
      
      total_amount = expense_items.sum { |item| (item['amount'] || item[:amount] || 0).to_f }
      table_data << [{ content: "Total:", font_style: :bold }, { content: "PHP #{number_with_precision(total_amount, precision: 2)}", font_style: :bold }]
      
      table(table_data, width: 500, header: true, cell_style: { padding: 8, border_width: 1 }) do
        row(0).font_style = :bold
        row(0).background_color = "E5E7EB"
        columns(1).align = :right
        row(-1).background_color = "F3F4F6"
      end
    else
      text "No expense breakdown available", style: :italic
    end
  end

  def status_section
    text "Status Information", size: 16, style: :bold
    move_down 5
    stroke_horizontal_rule
    move_down 10
    
    data = [
      ["Manager Status:", @cash_advance_request.manager_status&.humanize || "N/A"],
      ["Finance Status:", @cash_advance_request.finance_department_status&.humanize || "N/A"],
      ["Created At:", @cash_advance_request.created_at.strftime("%B %d, %Y at %I:%M %p")]
    ]
    
    table(data, width: 500, cell_style: { padding: 5, border_width: 0 }) do
      columns(0).font_style = :bold
      columns(0).width = 150
    end
  end

  def notes_section
    if @cash_advance_request.manager_reject_notes.present? || @cash_advance_request.finance_department_documentation_notes.present?
      move_down 10
      text "Notes", size: 16, style: :bold
      move_down 5
      stroke_horizontal_rule
      move_down 10
      
      if @cash_advance_request.manager_reject_notes.present?
        text "Manager Rejection Notes:", size: 12, style: :bold
        text safe_text(@cash_advance_request.manager_reject_notes), size: 10
        move_down 10
      end
      
      if @cash_advance_request.finance_department_documentation_notes.present?
        text "Finance Department Documentation Notes:", size: 12, style: :bold
        text safe_text(@cash_advance_request.finance_department_documentation_notes), size: 10
      end
    end
  end

  def footer
    repeat(:all) do
      bounding_box([bounds.left, bounds.bottom + 50], width: bounds.width) do
        stroke_horizontal_rule
        move_down 5
        text "Generated on #{Time.current.strftime('%B %d, %Y at %I:%M %p')}", size: 8, align: :center
      end
    end
  end

  def number_with_precision(number, precision: 2)
    sprintf("%.#{precision}f", number)
  end

  # Helper method to ensure text is compatible with Prawn's default fonts
  def safe_text(text)
    return "" if text.nil?
    # Convert to string and remove any problematic characters
    text.to_s.encode('ASCII', 'UTF-8', invalid: :replace, undef: :replace, replace: '')
  rescue
    text.to_s
  end
end

