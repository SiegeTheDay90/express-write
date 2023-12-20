class TempLetter < ApplicationRecord

    before_validation :ensure_secure_id

    def ensure_secure_id
        self.secure_id ||= SecureRandom.urlsafe_base64
    end
end
