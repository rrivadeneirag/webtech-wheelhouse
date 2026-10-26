class AddRoleToUsers < ActiveRecord::Migration[8.1]
  def change
    # The default is the role with the fewest permissions (see docs/decisions.md).
    add_column :users, :role, :string, null: false, default: "counter"
  end
end
