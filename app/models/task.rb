class Task < ApplicationRecord
  belongs_to :user
  has_many :task_records, dependent: :destroy
  validates :name, presence: true, length: { maximum: 30 }

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

    level = record.level
    is_level_up = false
    loop do
      # 次のレベルになるために必要な累積経験値を計算
      require_exp = EX_REQUIRED_TO_LEVEL_UP.slice(0, level).sum

      # レベルアップしたかどうか(99以上の場合はレベルアップなし)
      if exp >= require_exp && level < 99
        is_level_up = true
        level += 1
        record.update(level: level)
      else
        break
      end
    end


    record.update(exp: exp)

    Rails.logger.info record
    Rails.logger.info self

    return record, is_level_up
  end

  def is_reset_date(task_record)
    # 週の始まりを日曜日とする
    # TODO: 週の始まりを選べる機能を追加

    # 記録した日が日曜日
    return true if task_record.created_at.to_date.wday == 0

    # 記録日の週の日曜日を取得
    this_monday = task_record.created_at.to_date - task_record.created_at.to_date.wday

    # 前回の記録が今週の日曜日よりも前
    return true if !self.last_time.nil? && self.last_time.to_date < this_monday

    return false
  end
end
