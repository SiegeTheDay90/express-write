# frozen_string_literal: true

# == Schema Information
#
# Table name: profiles
#
#  id         :bigint           not null, primary key
#  title      :string           not null
#  industry   :string           default("")
#  aboutme    :text             default("")
#  skills     :text             default([]), is an Array
#  education  :text             default([]), is an Array
#  experience :text             default([]), is an Array
#  projects   :string           default([]), is an Array
#  user_id    :bigint
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
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
