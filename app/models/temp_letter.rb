# frozen_string_literal: true

# == Schema Information
#
# Table name: temp_letters
#
#  id         :bigint           not null, primary key
#  profile    :string           not null
#  listing    :string           not null
#  body       :string           not null
#  secure_id  :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class TempLetter < ApplicationRecord
  validates :body, presence: true
  has_rich_text :content
  before_validation :ensure_secure_id

  def body=(val)
    content.body = val.gsub("\n", '<br>')
    super(val)
  end

  def ensure_secure_id
    self.secure_id ||= SecureRandom.urlsafe_base64
  end
end
