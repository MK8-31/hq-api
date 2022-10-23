require 'rails_helper'

RSpec.describe Task, type: :model do
  before do
    @user = create(:user)
    @job = create(:warrior)
    @record = @user.records.create(job_id: @job.id)
  end

  it '作成成功' do
    task = @user.tasks.build(name: 'do hello')
    expect(task.valid?).to eq true
  end

  it 'タスク名がない場合に失敗' do
    task = @user.tasks.build(name: '')
    expect(task.valid?).to eq false
  end

  it 'タスク名が30文字より多い場合失敗' do
    task = @user.tasks.build(name: 'a' * 31)
    expect(task.valid?).to eq false
  end

  it 'task_record_saveが正常に機能しているか' do
    task = @user.tasks.create(name: 'do hello')
    task_record = task.task_records.create
    task.task_record_save(task_record, @record)
    expect(@record.exp).to eq 5
    expect(task.last_time).to eq task_record.created_at.to_date
    expect(task.day).to eq  (Date.today - task.created_at.to_date).to_i
    expect(task.days_a_week).to eq 1
    expect(task.running_days).to eq 0
  end
end
