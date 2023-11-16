class Request < ApplicationRecord
    validates :resource_type, inclusion: {in: %w[letter listing bio]}

    def complete!(status, errors="")
        self.complete = true
        self.ok = status
        self.messages = errors
        self.save!
    end

end
