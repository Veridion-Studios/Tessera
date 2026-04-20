class Passkey < ApplicationRecord
  belongs_to :user

  before_validation :normalize_external_id

  validates :label,       presence: true
  validates :external_id, presence: true, uniqueness: true
  validates :public_key,  presence: true

  private

  def normalize_external_id
    return if external_id.blank?

    decoded = Base64.urlsafe_decode64(pad_base64(external_id.to_s.tr("+", "-").tr("/", "_")))
    self.external_id = Base64.urlsafe_encode64(decoded, padding: false)
  rescue ArgumentError
    # Keep original value if normalization fails so validation can surface issues.
    external_id
  end

  def pad_base64(str)
    padding = (4 - (str.length % 4)) % 4
    str + ("=" * padding)
  end
end