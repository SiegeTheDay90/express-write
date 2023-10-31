# == Schema Information
#
# Table name: letters
#
#  id         :bigint           not null, primary key
#  body       :text             not null
#  config     :text             default("")
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  listing_id :bigint
#  user_id    :bigint
#
class Letter < ApplicationRecord
   belongs_to :listing
   has_rich_text :content

   has_one :author,
   through: :listing,
   source: :user
end
