class AddJobIdToUser < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :job_id, :integer, default: 1
  end
end
