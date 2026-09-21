class Repair < ApplicationRecord
  belongs_to :bike
  belongs_to :mechanic, class_name: "Staff", optional: true
  has_many :repair_services, dependent: :destroy
  has_many :services, through: :repair_services

  enum :status, {
    received:          "Received",
    assessed:          "Assessed",
    awaiting_approval: "Awaiting approval",
    approved:          "Approved",
    declined:          "Declined",
    in_progress:       "In progress",
    ready:             "Ready",
    collected:         "Collected"
  }, default: :received

  validates :received_at, presence: true
  validates :status, presence: true
  validate :dates_in_order
  validate :hand_back_matches_state

  scope :newest_first, -> { order(received_at: :desc) }
  scope :in_shop,      -> { where(handed_back_at: nil) }
  scope :overdue,      -> { in_shop.where("promised_on < ?", Date.current) }

  def overdue?
    handed_back_at.nil? && promised_on.present? && promised_on < Date.current
  end

  def total
    repair_services.sum(&:charged_price)
  end

  private

  def dates_in_order
    return if received_at.blank?

    if handed_back_at.present? && handed_back_at < received_at
      errors.add(:handed_back_at, "cannot be earlier than when the bike was received")
    end
    if promised_on.present? && promised_on < received_at.to_date
      errors.add(:promised_on, "cannot be earlier than the day the bike was received")
    end
  end

  def hand_back_matches_state
    if collected? && handed_back_at.blank?
      errors.add(:handed_back_at, "must be set once the bike has been collected")
    elsif !collected? && handed_back_at.present?
      errors.add(:handed_back_at, "should be empty until the bike is collected")
    end
  end
end
