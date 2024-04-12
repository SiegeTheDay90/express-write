# frozen_string_literal: true

# == Schema Information
#
# Table name: requests
#
#  id            :bigint           not null, primary key
#  complete      :boolean          default(FALSE)
#  ok            :boolean
#  messages      :string           default("")
#  resource_type :string           not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  resource_id   :string
#
class Request < ApplicationRecord
  validates :resource_type, inclusion: { in: %w[letter listing bio temp_letter] }

  def complete!(status, resource_id, messages = [''])
    return if complete

    self.resource_id ||= resource_id
    self.complete = true
    self.ok = status
    self.messages = messages
    save!
  end
end
