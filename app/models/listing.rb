# == Schema Information
#
# Table name: listings
#
#  id              :bigint           not null, primary key
#  company         :string           not null
#  job_title       :string           not null
#  job_description :text             default("")
#  requirements    :string           default([]), is an Array
#  benefits        :string           default([]), is an Array
#  user_id         :bigint
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
class Listing < ApplicationRecord
    belongs_to :user
    has_many :letters
end
