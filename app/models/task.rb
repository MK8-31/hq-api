class Task < ApplicationRecord
  belongs_to :user
  has_many :task_records, dependent: :destroy
  validates :name, presence: true, length: { maximum: 30 }
end
