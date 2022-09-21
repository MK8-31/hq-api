class CreateRecords < ActiveRecord::Migration[6.1]
  def change
    create_table :records do |t|
      t.integer :level, default: 1
      t.integer :exp, default: 0
      t.references :user, null: false, foreign_key: true
      t.references :job, null: false, foreign_key: true

      t.timestamps
    end
    add_index :records, %i[user_id job_id], unique: true
  end
end
