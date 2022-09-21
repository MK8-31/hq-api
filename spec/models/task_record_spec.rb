require 'rails_helper'

RSpec.describe TaskRecord, type: :model do
  before do
    @current_user = create(:user)
    2.times { |n| @current_user.tasks.create(name: "task-#{n}") }
    @task1 = @current_user.tasks.first
  end

  it '作成成功' do
    task_record = @task1.task_records.build
    expect(task_record.valid?).to eq true
  end
end
