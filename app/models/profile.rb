class Profile < ApplicationRecord
    # validates :title, presence: true, length: {minimum: 3, message: "must be at least 3 characters."}
    
    belongs_to :user

    def is_active?
        user&.active_profile == id
    end

    def set_active
        user.update!(active_profile: id)
    end
end
