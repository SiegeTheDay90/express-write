# == Schema Information
#
# Table name: sessions
#
#  id              :bigint           not null, primary key
#  session_id      :string           not null
#  ip_address      :string
#  hits            :integer          default(0)
#  tokens          :integer          default(5)
#  user_agent      :string
#  last_request_id :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
class Session < ApplicationRecord
    
    has_many :requests,
    primary_key: :session_id,
    foreign_key: :session_id
end
  
