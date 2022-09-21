# frozen_string_literal: true

class User < ActiveRecord::Base
  has_many :records, dependent: :destroy
  has_many :tasks, dependent: :destroy

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable,
         :registerable,
         :recoverable,
         :rememberable,
         :validatable

  #  :confirmable
  include DeviseTokenAuth::Concerns::User

  validates :nickname, presence: true, uniqueness: true
end
