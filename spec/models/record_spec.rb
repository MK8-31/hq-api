require 'rails_helper'

RSpec.describe Record, type: :model do
  it '作成成功' do
    user = create(:user)
    job = create(:warrior)
    record = user.records.build(job_id: job.id)
    expect(record.valid?).to eq true
  end

  it 'user_idがない場合に失敗' do
    job = create(:warrior)
    record = job.records.build(user_id: nil)
    expect(record.valid?).to eq false
  end

  it 'job_idがない場合に失敗' do
    user = create(:user)
    record = user.records.build(job_id: nil)
    expect(record.valid?).to eq false
  end

  it 'user_idとjob_idの組み合わせが一意でない場合に失敗' do
    user = create(:user)
    job = create(:warrior)
    record1 = user.records.create(job_id: job.id)
    record2 = user.records.build(job_id: job.id)
    expect(record2.valid?).to eq false
  end
end
