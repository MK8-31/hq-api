class CreateTasks < ActiveRecord::Migration[6.1]
  def change
    create_table :tasks do |t|
      t.string :name
      t.integer :day, default: 0
      t.integer :week, default: 0
      t.integer :days_a_week, default: 0
      t.integer :running_days, default: 0
      t.integer :running_weeks, default: 0
      t.date :last_time
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
    add_index :tasks, %i[user_id created_at]
  end
end
