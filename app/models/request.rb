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
  validates :resource_type, inclusion: %w[letter listing resume temp_letter]
  before_validation :update_session

  belongs_to :session,
    primary_key: :session_id,
    optional: true

  def self.average_uptime(range = (Date.today-7.days..DateTime.now))
    raise TypeError unless range.class == Range

    successful_requests = self.where(ok: true, created_at: range) 
    avg = successful_requests.length > 0 ? successful_requests.inject(0) { |acc, request| acc + request.uptime }/successful_requests.length : "No Requests"
  end

  def complete!(status, resource_id, messages = [''])
    return if complete

    self.resource_id ||= resource_id
    self.complete = true
    self.ok = status
    self.messages = messages
    save!
  end

  def uptime
    (self.updated_at - self.created_at)
  end

  def update_session
    return false unless self.session
    self.session.update!(last_request_id: id)
  end
end
