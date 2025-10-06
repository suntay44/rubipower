class Invoice < ApplicationRecord
  has_many_attached :supporting_documents

  validates :invoice_type, presence: true
  validates :company_name, presence: true
  validates :company_address, presence: true
  validates :company_contact, presence: true
  validates :client_name, presence: true
  validates :client_company, presence: true
  validates :client_address, presence: true
  validates :invoice_number, presence: true, uniqueness: true
  validates :invoice_date, presence: true
  validates :due_date, presence: true
  validates :description, presence: true
  validates :rates_and_quantities, presence: true
  validates :total_amount_due, presence: true, numericality: { greater_than: 0 }
  validates :payment_instructions, presence: true

  enum :invoice_type, { partial: 0, downpayment: 1, fullpayment: 2 }

  before_validation :generate_invoice_number, on: :create

  private

  def generate_invoice_number
    return if invoice_number.present?

    loop do
      self.invoice_number = "INV-#{Date.current.strftime('%Y%m%d')}-#{SecureRandom.hex(4).upcase}"
      break unless Invoice.exists?(invoice_number: invoice_number)
    end
  end
end
