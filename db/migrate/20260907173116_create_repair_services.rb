class CreateRepairServices < ActiveRecord::Migration[8.1]
  def change
    create_table :repair_services do |t|
      t.references :repair, null: false, foreign_key: false
      t.references :service, null: false, foreign_key: false
      t.decimal :charged_price, precision: 8, scale: 2, null: false

      t.timestamps
    end
  end
end
