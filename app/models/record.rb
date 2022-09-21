class Record < ApplicationRecord
  belongs_to :user
  belongs_to :job

  validates :user_id, presence: true, uniqueness: { scope: [:job_id] }
  validates :job_id, presence: true
end
