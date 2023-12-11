class Profile < ApplicationRecord
    validates :title, :industry, presence: true
    
    belongs_to :user

    def is_active?
        user&.active_profile == id
    end

    def set_active
        user.update!(active_profile: id)
    end
end
