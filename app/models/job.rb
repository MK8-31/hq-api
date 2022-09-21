class Job < ApplicationRecord
  has_many :records
  validates :name, presence: true, uniqueness: true
end
