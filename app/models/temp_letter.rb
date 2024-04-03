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
    has_rich_text :content
    before_validation :ensure_secure_id

    def ensure_secure_id
        self.secure_id ||= SecureRandom.urlsafe_base64
    end
end
