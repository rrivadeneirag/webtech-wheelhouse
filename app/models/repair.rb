class Repair < ApplicationRecord
  belongs_to :bike
  belongs_to :mechanic, class_name: "Staff", optional: true
  has_many :repair_services
end
