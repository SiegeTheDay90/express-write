# == Schema Information
#
# Table name: requests
#
#  id            :bigint           not null, primary key
#  complete      :boolean          default(FALSE)
#  ok            :boolean
#  messages      :string           default("")
#  resource_type :string           not null
#  resource_id   :bigint
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
class Request < ApplicationRecord
    validates :resource_type, inclusion: {in: %w[letter listing bio temp_letter]}

    def complete!(status, resource_id, messages=[""])
        return if self.complete
        self.resource_id ||= resource_id
        self.complete = true
        self.ok = status
        self.messages = messages
        self.save!
    end

end
