class Task < ApplicationRecord
  belongs_to :user
  has_many :task_records, dependent: :destroy
  validates :name, presence: true, length: { maximum: 30 }

  Cumulative_experience = [
    0,
    12,
    30,
    57,
    98,
    159,
    250,
    387,
    592,
    900,
    1361,
    2053,
    3091,
    4648,
    6983,
    10486,
    15741,
    23623,
    35446,
    53181,
    79783,
    119686,
    179541,
    269323,
    403996,
    606005,
    909019,
    1363540,
    2045322,
    3067994,
    4602002,
    6903015,
    10354534,
    15531813,
    23297731,
    34946608,
    52419923,
    78629896,
    117944855,
    176917294,
    265375953,
    398063941,
    597095923,
    895643896,
    1343465855,
    2015198793,
    3022798201,
    4534197313,
    6801295980,
    10201943981,
    15302915983,
    22954373986,
    34431560990,
    51647341496,
    77471012255,
    116206518393,
    174309777600,
    261464666411,
    392196999627,
    588295499451,
    882443249186,
    1323664873789,
    1985497310694,
    2978245966051,
    4467368949087,
    6701053423641,
    10051580135472,
    15077370203218,
    22616055304837,
    33924082957265,
    50886124435907,
    76329186653870,
    114493779980815,
    171740669971232,
    257611004956857,
    386416507435295,
    579624761152952,
    869437141729437,
    1304155712594165,
    1956233568891257,
    2934350353336894,
    4401525530005350,
    6602288295008033,
    9903432442512058,
    14855148663768096,
    22282722995652154,
    33424084493478238,
    50136126740217364,
    75204190110326056,
    112806285165489096,
    169209427748233656,
    253814141622350488,
    380721212433525736,
    571081818650288616,
    856622727975432936,
    1284934091963149416,
    1927401137944724072,
    2891101706917086056,
    4336652560375629160,
    6504978840563443816,
  ]
  Cumulative_experience.freeze

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
      require_exp = Cumulative_experience[level]

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
