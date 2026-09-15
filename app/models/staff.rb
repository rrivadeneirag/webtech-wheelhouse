class Staff < ApplicationRecord
  has_many :repairs, foreign_key: :mechanic_id, inverse_of: :mechanic
end
