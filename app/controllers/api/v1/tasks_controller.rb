class Api::V1::TasksController < ApplicationController
  before_action :authenticate_api_v1_user!
  before_action :set_task, only: %i[show update destroy]

  def index
    tasks = current_api_v1_user.tasks.all
    render json: { status: 'SUCCESS', message: 'Loaded tasks', data: tasks }
  end

  def show
    render json: { status: 'SUCCESS', message: 'Loaded the task', data: @task }
  end

  def create
    task = current_api_v1_user.tasks.build(task_params)
    if task.save
      render json: { status: 'SUCCESS', data: task }
    else
      render json: { status: 'ERROR', data: task.errors }
    end
  end

  def destroy
    @task.destroy
    render json: { status: 'SUCCESS', message: 'Deleted the task', data: @task }
  end

  def update
    if @task.update(task_params)
      render json: {
               status: 'SUCCESS',
               message: 'Updated the post',
               data: @task,
             }
    else
      render json: {
               status: 'ERROR',
               message: 'Not updated',
               data: @task.errors,
             }
    end
  end

  private

  def set_task
    @task = Task.find(params[:id])
  end

  def task_params
    params.require(:task).permit(:name)
  end
end
