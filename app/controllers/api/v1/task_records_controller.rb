class Api::V1::TaskRecordsController < ApplicationController
  before_action :authenticate_api_v1_user!
  before_action :set_task, only: %i[create]
  before_action :set_record, only: %i[create]

  def create
    latest_task_record = @task.task_records.order(created_at: :desc).limit(1)[0]

     # 同じ日に記録がないかを確認する
    if latest_task_record && latest_task_record.created_at.today?
      render json: {
               status: 'ERROR',
               message: 'すでに記録済みです',
             },
             status: 401
      return
    end

    task_record = @task.task_records.build

    ActiveRecord::Base.transaction do
      if task_record.save
        # タスクの記録の更新とユーザの記録(経験値・レベル)を更新する

        @record, is_level_up = @task.task_record_save(task_record, @record)

        render json: {
                status: 'SUCCESS',
                data: @record,
                is_level_up: is_level_up,
              }
      else
        Rails.logger.info task_record.errors
        render json: { status: 'ERROR', data: task_record.errors }
      end
    end

  rescue
    render json: {
      status: 'ERROR',
      message: '処理の途中でエラーが発生したため、記録されませんでした',
    },
    status: 500
    return
  end

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
