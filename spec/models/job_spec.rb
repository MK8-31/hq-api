require 'rails_helper'

RSpec.describe Job, type: :model do
  it '名前があり、一意であるとき有効' do
    job = build(:warrior)
    expect(job.valid?).to eq true
  end

  it '名前がない場合、無効' do
    job = Job.create(name: '')
    expect(job.valid?).to eq false
  end

  it '名前が重複している場合、無効' do
    job = create(:warrior)
    warrior = Job.create(name: 'Warrior')
    expect(warrior.valid?).to eq false
  end
end
