require 'rails_helper'

RSpec.describe 'Api::V1::TaskRecords', type: :request do
  before do
    @current_user = create(:user)
    2.times { |n| @current_user.tasks.create(name: "task-#{n}") }
    @task1 = @current_user.tasks.first
    @task2 = @current_user.tasks.second
  end

  describe 'create' do
    it 'ログイン状態でタスクの記録を作成する' do
      auth_token = login(@current_user)
      params = { task: { id: @task1.id } }
      last_time = @task1.last_time
      expect {
        post '/api/v1/task_records', params: params, headers: auth_token
      }.to change(TaskRecord, :count).by(+1)

      json = JSON.parse(response.body)
      data = json['data']

      expect(response.status).to eq(200)

      # タスクのlast_timeが書き変わるか
      expect(@task1.reload.last_time).not_to eq(last_time)
    end

    it 'ログイン状態で同じ日に2回同じタスクの記録を作成する' do
      auth_token = login(@current_user)
      params = { task: { id: @task1.id } }
      last_time = @task1.last_time
      expect {
        post '/api/v1/task_records', params: params, headers: auth_token
      }.to change(TaskRecord, :count).by(+1)

      expect {
        post '/api/v1/task_records', params: params, headers: auth_token
      }.to change(TaskRecord, :count).by(0)

      json = JSON.parse(response.body)
      message = json['message']

      expect(response.status).not_to eq(200)

      expect(message).to eq('すでに記録済みです')
    end
  end

  # describe 'destroy' do
  #   it 'ログイン状態でタスクの記録を削除する' do
  #     auth_token = login(@current_user)
  #     params = { task: { id: @task1.id } }

  #     expect {
  #       post '/api/v1/task_records', params: params, headers: auth_token
  #     }.to change(TaskRecord, :count).by(+1)

  #     task_record =
  #       @task1.task_records.where(created_at: Time.zone.now.all_day)[0]

  #     expect {
  #       delete "/api/v1/task_records/#{@task1.id}", headers: auth_token
  #     }.to change(TaskRecord, :count).by(-1)

  #     json = JSON.parse(response.body)
  #     data = json['data']

  #     expect(response.status).to eq(200)

  #     expect(data['id']).to eq(task_record.id)
  #   end

  #   it 'ログイン状態でかつ、今日のタスクの記録がない状態でタスクの記録を削除する' do
  #     auth_token = login(@current_user)
  #     params = { task: { id: @task1.id } }

  #     expect {
  #       delete "/api/v1/task_records/#{@task1.id}", headers: auth_token
  #     }.to change(TaskRecord, :count).by(0)

  #     json = JSON.parse(response.body)
  #     message = json['message']

  #     expect(response.status).not_to eq(200)

  #     expect(message).to eq('今日記録したタスクレコードはありません。')
  #   end

  #   it 'ログイン状態でタスクの記録を削除するとタスクのlast_timeが前回記録した時間になる' do
  #     auth_token = login(@current_user)
  #     yesterday_time = Date.yesterday
  #     @task1.task_records.create(created_at: yesterday_time)
  #     params = { task: { id: @task1.id } }

  #     expect {
  #       post '/api/v1/task_records', params: params, headers: auth_token
  #     }.to change(TaskRecord, :count).by(+1)

  #     json = JSON.parse(response.body)
  #     data = json['data']

  #     expect(data['last_time']).not_to eq(yesterday_time)

  #     expect {
  #       delete "/api/v1/task_records/#{@task1.id}", headers: auth_token
  #     }.to change(TaskRecord, :count).by(-1)

  #     json = JSON.parse(response.body)
  #     data = json['data']

  #     expect(response.status).to eq(200)

  #     expect(@task1.reload.last_time).to eq(yesterday_time)
  #   end
  # end
end
