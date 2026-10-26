class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy

  # An account may belong to one staff member (and a staff member to at most one
  # account — the unique index enforces that side).
  belongs_to :staff, optional: true

  # The role is a string column, declared as an enum here. The default is the
  # role with the fewest permissions (see docs/decisions.md).
  enum :role, { counter: "counter", mechanic: "mechanic", owner: "owner" }, default: :counter

  MINIMUM_PASSWORD_LENGTH = 10

  # Emails are compared without regard to case: they are stored lower-cased, so
  # Ana@wheelhouse.cl and ana@wheelhouse.cl are the same account.
  normalizes :email_address, with: ->(e) { e.strip.downcase }

  validates :email_address, presence: true,
                            uniqueness: { case_sensitive: false },
                            format: { with: URI::MailTo::EMAIL_REGEXP, message: "is not a valid email address" }

  validates :password, length: { minimum: MINIMUM_PASSWORD_LENGTH,
                                 message: "must be at least #{MINIMUM_PASSWORD_LENGTH} characters long" },
                       allow_nil: true

  # The name to show for this account: the staff member's, or the email.
  def display_name
    staff&.name || email_address
  end
end
