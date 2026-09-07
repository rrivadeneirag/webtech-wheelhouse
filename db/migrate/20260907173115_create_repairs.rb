class CreateRepairs < ActiveRecord::Migration[8.1]
  def change
    create_table :repairs do |t|
      t.references :bike, null: false, foreign_key: false
      t.references :mechanic, null: true, foreign_key: false
      t.string :status, null: false, default: "Received"
      t.datetime :received_at, null: false
      t.date :promised_on
      t.datetime :handed_back_at

      t.timestamps
    end
  end
end
