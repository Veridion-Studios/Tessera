class InvoiceLineItem < ApplicationRecord
  belongs_to :invoice

  validates :description, presence: true
  validates :quantity, numericality: { greater_than: 0 }
  validates :unit_amount, numericality: { greater_than_or_equal_to: 0 }

  before_save :compute_amount

  private

  def compute_amount
    self.amount = quantity * unit_amount
  end
end