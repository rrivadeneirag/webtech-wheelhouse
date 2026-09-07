class CreateBikes < ActiveRecord::Migration[8.1]
  def change
    create_table :bikes do |t|
      t.string :make_model, null: false
      t.string :serial_number, null: false
      t.string :colour
      t.references :customer, null: false, foreign_key: false

      t.timestamps
    end
    add_index :bikes, :serial_number, unique: true
  end
end
