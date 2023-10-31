# == Schema Information
#
# Table name: users
#
#  id                     :bigint           not null, primary key
#  email                  :string           default(""), not null
#  password_digest        :string           default(""), not null
#  reset_password_token   :string
#  reset_password_sent_at :datetime
#  first_name             :string           default("")
#  last_name              :string           default("")
#  skills                 :text             default([]), is an Array
#  education              :text             default([]), is an Array
#  experience             :text             default([]), is an Array
#  completion             :integer          default(0)
#  industry               :string           default("")
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  provider               :string
#  uid                    :string
#  username               :string
#  session_token          :string
#  aboutme                :text             default("")
#  projects               :string           default([]), is an Array
#
class User < ApplicationRecord
    validates :username, :email, :password_digest, uniqueness: true, presence: true
    validates :first_name, :last_name, presence: true
    before_validation :ensure_username, :ensure_session_token
    has_secure_password

    has_many :listings, dependent: :destroy
    has_many :letters, through: :listings, source: :letters

    def ensure_username
        self.username = self.email
    end

    def full_name
      "#{first_name} #{last_name}"
    end

    def bio_update(bio)
      for key in bio.keys
        self[key] = bio[key]
      end
    end

    def self.omni_authorize(info_hash)
      user_options = {
        provider: "linkedin",
        first_name: info_hash["given_name"],
        last_name: info_hash["family_name"],
        email: info_hash["email"],
        industry: info_hash["headline"],
        uid: info_hash["sub"],
        password_digest: SecureRandom.urlsafe_base64
      }


      user = User.find_by({provider: "linkedin", uid: info_hash["sub"]})

      if !user
        user = User.create!(user_options)
      end
      return user
    end

    def self.find_by_credentials(credential, password)
        user = User.find_by(email: credential.downcase)

        if user
          return user.authenticate(password)
        else
          return nil
        end
    end
    
    def reset_session_token!
      self.update!(session_token: generate_unique_session_token)
      self.session_token
    end
  
    def ensure_session_token
      self.session_token ||= generate_unique_session_token
    end
  
  
    private
  
    def generate_unique_session_token
      token = SecureRandom::urlsafe_base64
  
      while User.exists?(session_token: token)
          token = SecureRandom::urlsafe_base64
      end
  
      token
    end
end
