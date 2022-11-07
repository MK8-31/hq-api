class AddTestLoginToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :test_login, :boolean, default: false
  end
end
