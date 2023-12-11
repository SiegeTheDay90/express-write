class Profile < ApplicationRecord
    
    belongs_to :user

    def is_active?
        user.active_profile == id
    end

    def set_active
        user.update!(active_profile: id)
    end
end
