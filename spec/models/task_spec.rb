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

  describe '#task_record_save' do
    it 'task_record_saveが正常に機能しているか' do
      task = @user.tasks.create(name: 'do hello')
      task_record = task.task_records.create
      Rails.logger.info @record
      task.task_record_save(task_record, @record)
      expect(@record.exp).to eq 6
      expect(task.last_time).to eq task_record.created_at.to_date
      expect(task.day).to eq  1
      expect(task.days_a_week).to eq 1
      expect(task.running_days).to eq 1
    end

    it 'days_a_weekが日曜日に適切にリセットされるか' do
      # 日曜日
      travel_to Date.today - Date.today.wday do
        task1 = @user.tasks.create(name: 'task1', days_a_week: 4, last_time: 1.days.ago)
        task2 = @user.tasks.create(name: 'task2', days_a_week: 4, last_time: 2.days.ago)
        task_record1 = task1.task_records.create
        task_record2 = task2.task_records.create
        task1.task_record_save(task_record1, @record)
        task2.task_record_save(task_record2, @record)
        expect(task1.days_a_week).to eq 1
        expect(task2.days_a_week).to eq 1
      end
    end

    it 'days_a_weekが前回の記録によって適切にリセットされるか' do
      # 土曜日
      travel_to Date.today - (Date.today.wday - 6) do
        task1 = @user.tasks.create(name: 'task1', days_a_week: 4, last_time: 1.days.ago)
        task2 = @user.tasks.create(name: 'task2', days_a_week: 4, last_time: 7.days.ago)
        task_record1 = task1.task_records.create
        task_record2 = task2.task_records.create
        task1.task_record_save(task_record1, @record)
        task2.task_record_save(task_record2, @record)
        expect(task1.days_a_week).to eq 5
        expect(task2.days_a_week).to eq 1
      end
    end

    it '同じ週で継続している場合にdays_a_weekがリセットされない' do
      task = @user.tasks.create(name: 'do hello')
      sunday = Date.today - Date.today.wday
      7.times do |i|
        travel_to sunday + i do
          task_record = task.task_records.create
          task.task_record_save(task_record, @record)
          expect(task.days_a_week).to eq 1+i
          expect(task.day).to eq  1+i
          expect(task.running_days).to eq 1+i
        end
      end
    end

    it 'running_daysが正常に稼働しているか' do
      task1 = @user.tasks.create(name: 'task1', created_at: 7.days.ago, days_a_week: 4, last_time: 1.days.ago, running_days: 6)
      task2 = @user.tasks.create(name: 'task2', created_at: 8.days.ago, days_a_week: 4, last_time: 2.days.ago, running_days: 6)
      task_record1 = task1.task_records.create
      task_record2 = task2.task_records.create
      task1.task_record_save(task_record1, @record)
      task2.task_record_save(task_record2, @record)
      expect(task1.running_days).to eq 7
      expect(task2.running_days).to eq 1
    end

    it 'running_weeksが正常に稼働しているか' do
      task1 = @user.tasks.create(name: 'task1', created_at: 27.days.ago, days_a_week: 3, last_time: 1.days.ago, running_weeks: 2)
      task2 = @user.tasks.create(name: 'task2', created_at: 27.days.ago, days_a_week: 4, last_time: 2.days.ago, running_weeks: 2)
      task_record1 = task1.task_records.create
      task_record2 = task2.task_records.create
      task1.task_record_save(task_record1, @record)
      task2.task_record_save(task_record2, @record)
      expect(task1.running_weeks).to eq 3
      expect(task2.running_weeks).to eq 2
    end
  end
end
