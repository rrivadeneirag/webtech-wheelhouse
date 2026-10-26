class AddTakenInByToRepairs < ActiveRecord::Migration[8.1]
  def change
    # The account that took the repair in. Null for repairs that existed before
    # the column (and for a couple of seed repairs).
    add_reference :repairs, :taken_in_by, null: true, foreign_key: { to_table: :users }
  end
end
