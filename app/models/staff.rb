class Staff < ApplicationRecord
  # A staff member who has an account cannot be destroyed.
  has_one :user, dependent: :restrict_with_error

  has_many :repairs, foreign_key: :mechanic_id, inverse_of: :mechanic, dependent: :nullify

  validates :name, presence: true
  validates :role, presence: true

  scope :by_name, -> { order(:name) }
end
