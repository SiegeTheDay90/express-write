class Site < ApplicationRecord
  validates :name, :url, presence: true
  validates :url, uniqueness: true
end
