class Api::V1::TaskRecordsController < ApplicationController
  before_action :authenticate_api_v1_user!
  before_action :set_task, only: %i[create]
  before_action :set_record, only: %i[create]

  def create
    latest_task_record = @task.task_records.order(created_at: :desc).limit(1)[0]

    if latest_task_record && latest_task_record.created_at.today?
      render json: {
               status: 'ERROR',
               message: 'すでに記録済みです',
             },
             status: 401
      return
    end

    task_record = @task.task_records.build

    # 同じ日に記録がないかを確認する
    if task_record.save
      # taskのlast_timeを更新
      @task.update(last_time: task_record.created_at)
      exp = @record.exp

      # 経験値を更新
      # タスクを達成したことによる経験値
      exp = @record.exp += 5

      @task.update(day: (Date.today - @task.created_at.to_date).to_i)

      week = ((Date.today - @task.created_at.to_date) / 7).to_i
      if week != @task.week
        @task.update(week: week)

        # 週を跨いだらリセット
        @task.update(days_a_week: 0)
      end

      # 週に何回タスクを達成したか

      @task.update(days_a_week: @task.days_a_week += 1)

      # 週に4回以上タスクを行うとボーナス
      exp += @record.lv * 100 if @task.days_a_week >= 4

      if @task.days_a_week == 4
        @task.update(running_weeks: @task.running_weeks += 1)

        # 続いている週数によってボーナス
        exp += @task.running_weeks * 100
      end

      # 連続してタスクを達成によるボーナス
      if (Date.today - @task.last_time).to_i == 1
        @task.update(running_days: @task.running_days += 1)
        exp += @task.running_days * @record.level
      end

      previous_level = @record.level

      # レベルの計算式、レベル1からレベル２に必要な経験値を１２、倍率を1.５倍に設定
      level =
        p ((Math.log(1 - (exp / 12.0) * (1 - 1.5)) / Math.log(1.5)) + 1).floor

      is_level_up = (previous_level < level) ? true : false

      @record.update(exp: exp, level: level)

      render json: {
               status: 'SUCCESS',
               data: @record,
               is_level_up: is_level_up,
             }
    else
      render json: { status: 'ERROR', data: task_record.errors }
    end
  end

  # def destroy
  #   task = Task.find(params[:id])

  #   # 今日の日付の範囲
  #   # range = Date.today.beginning_of_day..Date.today.end_of_day

  #   # 今日記録されたタスクレコード
  #   task_record = task.task_records.where(created_at: Time.zone.now.all_day)[0]

  #   if task_record.nil?
  #     render json: {
  #              status: 'ERROR',
  #              message: '今日記録したタスクレコードはありません。',
  #              data: task_record,
  #            },
  #            status: 401
  #     return
  #   end

  #   if task_record.destroy
  #     # 前回のタスクレコードを取得する
  #     latest_task_record =
  #       task.task_records.order(created_at: :desc).limit(1)[0]

  #     # taskのlast_timeを更新
  #     if latest_task_record.present?
  #       task.update(last_time: latest_task_record.created_at)
  #     else
  #       task.update(last_time: nil)
  #     end

  #     # 経験値を更新

  #     render json: {
  #              status: 'SUCCESS',
  #              message: 'タスクレコードを削除しました。',
  #              data: task_record,
  #            }
  #   else
  #     render json: {
  #              status: 'ERROR',
  #              message: 'タスクレコードの削除に失敗しました。',
  #              data: task_record,
  #            }
  #   end
  # end

  private

  def set_task
    @task = Task.find_by(task_record_params)
  end

  def task_record_params
    params.require(:task).permit(:id)
  end

  def set_record
    @record =
      current_api_v1_user.records.find_by(job_id: current_api_v1_user.job_id) ||
        current_api_v1_user.records.create(job_id: current_api_v1_user.job_id)
  end
end
