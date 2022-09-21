require 'rails_helper'

RSpec.describe Task, type: :model do
  before { @user = build(:user) }

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
end
