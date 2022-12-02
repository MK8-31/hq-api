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

    it 'レベルと経験値の整合性が取れているか' do
      EX_REQUIRED_TO_LEVEL_UP = [
        12,
        18,
        27,
        41,
        61,
        91,
        137,
        205,
        308,
        461,
        692,
        1038,
        1557,
        2335,
        3503,
        5255,
        7882,
        11823,
        17735,
        26602,
        39903,
        59855,
        89782,
        134673,
        202009,
        303014,
        454521,
        681782,
        1022672,
        1534008,
        2301013,
        3451519,
        5177279,
        7765918,
        11648877,
        17473315,
        26209973,
        39314959,
        58972439,
        88458659,
        132687988,
        199031982,
        298547973,
        447821959,
        671732938,
        1007599408,
        1511399112,
        2267098667,
        3400648001,
        5100972002,
        7651458003,
        11477187004,
        17215780506,
        25823670759,
        38735506138,
        58103259207,
        87154888811,
        130732333216,
        196098499824,
        294147749735,
        441221624603,
        661832436905,
        992748655357,
        1489122983036,
        2233684474554,
        3350526711831,
        5025790067746,
        7538685101619,
        11308027652428,
        16962041478642,
        25443062217963,
        38164593326945,
        57246889990417,
        85870334985625,
        128805502478438,
        193208253717657,
        289812380576485,
        434718570864728,
        652077856297092,
        978116784445637,
        1467175176668456,
        2200762765002683,
        3301144147504025,
        4951716221256038,
        7427574331884058,
        11141361497826084,
        16712042246739126,
        25068063370108692,
        37602095055163040,
        56403142582744560,
        84604713874116832,
        126907070811175248,
        190360606216762880,
        285540909325144320,
        428311363987716480,
        642467045981574656,
        963700568972361984,
        1445550853458543104,
        2168326280187814656,
      ]
      EX_REQUIRED_TO_LEVEL_UP.freeze

      Num_of_attempts = 30
      task = @user.tasks.create(name: 'do hello', created_at: Date.today - Num_of_attempts)
      Num_of_attempts.times do |i|
        travel_to (Date.today - Num_of_attempts) + i do
          task_record = task.task_records.create
          record, is_level_up = task.task_record_save(task_record, @record)
          # 今のレベルに必要な累積経験値
          Cumulative_experience = EX_REQUIRED_TO_LEVEL_UP.slice(0, record.level - 1).sum
          # 次のレベルに必要な累積経験値
          Next_cumulative_experience = EX_REQUIRED_TO_LEVEL_UP.slice(0, record.level).sum
          print("level = #{record.level}, exp = #{record.exp}, 今のレベルに必要な累積経験値 = #{Cumulative_experience}, 次のレベルに必要な累積経験値 = #{Next_cumulative_experience}\n")
          expect(record.exp >= Cumulative_experience && record.exp < Next_cumulative_experience).to eq true
        end
      end
    end
  end
end
