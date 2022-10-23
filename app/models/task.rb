class Task < ApplicationRecord
  belongs_to :user
  has_many :task_records, dependent: :destroy
  validates :name, presence: true, length: { maximum: 30 }

  def task_record_save(task_record, record)
    # taskのlast_timeを更新
    self.update(last_time: task_record.created_at)
    exp = record.exp

    # 経験値を更新
    # タスクを達成したことによる経験値
    exp = record.exp += 5

    self.update(day: (Date.today - self.created_at.to_date).to_i)

    week = ((Date.today - self.created_at.to_date) / 7).to_i
    if week != self.week
      self.update(week: week)

      # 週を跨いだらリセット
      self.update(days_a_week: 0)
    end

    # 週に何回タスクを達成したか

    self.update(days_a_week: self.days_a_week + 1)

    # 週に4回以上タスクを行うとボーナス
    exp += record.level * 100 if self.days_a_week >= 4

    if self.days_a_week == 4
      self.update(running_weeks: self.running_weeks + 1)

      # 続いている週数によってボーナス
      exp += self.running_weeks * 100
    end

    # 連続してタスクを達成によるボーナス
    if (Date.today - self.last_time).to_i == 1
      self.update(running_days: self.running_days + 1)
      exp += self.running_days * record.level
    end

    previous_level = record.level

    # レベルの計算式、レベル1からレベル２に必要な経験値を１２、倍率を1.５倍に設定
    level =
      p ((Math.log(1 - (exp / 12.0) * (1 - 1.5)) / Math.log(1.5)) + 1).floor

    is_level_up = (previous_level < level) ? true : false

    record.update(exp: exp, level: level)

    Rails.logger.info record
    Rails.logger.info self

    return record, is_level_up
  end
end
