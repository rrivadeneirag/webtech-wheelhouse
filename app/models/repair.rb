class Repair < ApplicationRecord
  # --- Intake photos (Active Storage) -------------------------------------------
  # Any number of photos, under one name, with two named variants whose sizes live
  # ONLY here: a small square for the lists and a larger one for the repair's page.
  has_many_attached :intake_photos do |attachable|
    attachable.variant :thumb, resize_to_fill: [96, 96]
    attachable.variant :card,  resize_to_limit: [1000, 1000]
  end

  # --- Diagnosis (Action Text) --------------------------------------------------
  # Optional rich text, stored in its own table (no column on repairs).
  has_rich_text :diagnosis

  # Which image types the shop's phones produce, and the size ceiling. Both are
  # model validations, so their messages reach the form like any other error.
  ACCEPTED_PHOTO_TYPES = %w[image/jpeg image/png image/heic image/heif image/webp].freeze
  MAX_PHOTO_BYTES = 10.megabytes

  belongs_to :bike
  # The account that took the repair in (set from the session, never a form).
  belongs_to :taken_in_by, class_name: "User", optional: true
  belongs_to :mechanic, class_name: "Staff", optional: true
  has_many :repair_services, dependent: :destroy
  has_many :services, through: :repair_services

  accepts_nested_attributes_for :repair_services,
                                allow_destroy: true,
                                reject_if: ->(attrs) { attrs["service_id"].blank? }

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
  validate :intake_photos_are_acceptable

  scope :newest_first, -> { order(received_at: :desc) }
  scope :in_shop,      -> { where(handed_back_at: nil) }
  scope :overdue,      -> { in_shop.where("promised_on < ?", Date.current) }

  def overdue?
    handed_back_at.nil? && promised_on.present? && promised_on < Date.current
  end

  def total
    repair_services.reject(&:marked_for_destruction?).sum { |line| line.charged_price || 0 }
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

  # Checks every attached photo (existing and newly added). If any file is the
  # wrong type or too big, the save is refused and the message names that file,
  # so not even the valid files of the same upload are attached.
  def intake_photos_are_acceptable
    intake_photos.each do |photo|
      next unless photo.blob

      unless ACCEPTED_PHOTO_TYPES.include?(photo.blob.content_type)
        errors.add(:intake_photos, "#{photo.filename} is not an accepted image — use JPEG, PNG, HEIC or WebP")
      end

      if photo.blob.byte_size.to_i > MAX_PHOTO_BYTES
        errors.add(:intake_photos, "#{photo.filename} is larger than #{MAX_PHOTO_BYTES / 1.megabyte} MB")
      end
    end
  end
end
