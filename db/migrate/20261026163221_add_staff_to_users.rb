class AddStaffToUsers < ActiveRecord::Migration[8.1]
  def change
    # An account may belong to one staff member; the unique index refuses a
    # second account for the same member. NULL is allowed (an account with no
    # staff member is valid), and Postgres permits many NULLs under a unique index.
    add_reference :users, :staff, null: true, foreign_key: true, index: { unique: true }
  end
end
