class Task < ApplicationRecord
  belongs_to :user
  has_many :task_records, dependent: :destroy
  validates :name, presence: true, length: { maximum: 30 }

  def task_record_save(task_record, record)
    # 経験値を更新
    # タスクを達成したことによる経験値
    exp = record.exp + 5

    # リセット日ならばリセット
    if is_reset_date(task_record)
      self.update(days_a_week: 0)
    end

    # 週に何回タスクを達成したか
    self.update(days_a_week: self.days_a_week + 1)

    # 連続してタスクを達成によるボーナス
    if self.last_time.nil? || (task_record.created_at.to_date - self.last_time.to_date).to_i == 1
      self.update(running_days: self.running_days + 1)
      exp += self.running_days * record.level
    else
      self.update(running_days: 1)
    end

    # taskのlast_timeを更新
    self.update(last_time: task_record.created_at)

    # taskの達成日数を１追加
    self.update(day: self.day + 1)

    # 週に4回以上タスクを行うとボーナス
    exp += record.level * 100 if self.days_a_week >= 4

    if self.days_a_week == 4
      self.update(running_weeks: self.running_weeks + 1)
      self.update(week: self.week + 1)

      # 続いている週数によってボーナス
      exp += self.running_weeks * 100
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

  def is_reset_date(task_record)
    # 次のリセット日までの日数
    days_until_next_reset_date = 7 - ((task_record.created_at.to_date - self.created_at.to_date) % 7)

    # 週の変わり目の場合
    return true if days_until_next_reset_date == 7

    # 次のリセット日
    next_reset_date = task_record.created_at.to_date + days_until_next_reset_date

    # 次のリセット日から前回の記録日が７日よりも離れていた場合
    return true if !self.last_time.nil? && (next_reset_date - self.last_time.to_date) > 7

    Rails.logger.debug task_record.created_at.to_date
    Rails.logger.debug self.created_at.to_date
    Rails.logger.debug days_until_next_reset_date
    Rails.logger.debug next_reset_date

    return false
  end
end
