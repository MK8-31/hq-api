require 'rails_helper'

RSpec.describe 'Api::V1::Tasks', type: :request do
  before do
    @current_user = create(:user)
    10.times { |n| @current_user.tasks.create(name: "task-#{n}") }
    other_user = create(:user2)
    10.times { |n| other_user.tasks.create(name: "task-#{n}") }
  end

  describe 'tasks controller test' do
    it 'ログイン状態ですべてのタスクを取得する' do
      # ログイン状態であることを証明するために必要なリクエストヘッダーの要素を取得
      # access-token, client, uid
      auth_token = login(@current_user)

      get '/api/v1/tasks', headers: auth_token
      json = JSON.parse(response.body)

      expect(response.status).to eq(200)

      expect(json['data'].length).to eq(10)
    end

    it '取得したタスクが自分のタスクである' do
      # ログイン状態であることを証明するために必要なリクエストヘッダーの要素を取得
      # access-token, client, uid
      auth_token = login(@current_user)

      get '/api/v1/tasks', headers: auth_token
      json = JSON.parse(response.body)

      expect(response.status).to eq(200)

      expect(json['data'].length).to eq(10)

      json['data'].length.times do |i|
        expect(json['data'][i]['user_id']).to eq(@current_user.id)
      end
    end

    it 'ログインしていない状態ですべてのタスクを取得するとエラー' do
      get '/api/v1/tasks'
      json = JSON.parse(response.body)

      expect(response.status).to eq(401)

      expect(json['errors'][0]).to eq(
        'ログインもしくはアカウント登録してください。',
      )
    end

    it 'ログイン状態で特定のタスクを取得' do
      task_name = 'スクワット100回'
      task = @current_user.tasks.create(name: task_name)

      auth_token = login(@current_user)

      get "/api/v1/tasks/#{task.id}", headers: auth_token

      # json から hash形式に変換
      json = JSON.parse(response.body)

      # data は array で返ってくることに注意
      data = json['data']

      expect(response.status).to eq(200)
      expect(data['name']).to eq(task_name)
    end

    it 'ログインしていない状態で特定のタスクを取得するとエラー' do
      task_name = 'スクワット100回'
      task = @current_user.tasks.create(name: task_name)

      get "/api/v1/tasks/#{task.id}"
      json = JSON.parse(response.body)

      expect(response.status).to eq(401)

      expect(json['errors'][0]).to eq(
        'ログインもしくはアカウント登録してください。',
      )
    end

    it 'ログイン状態でタスクを作成' do
      task_name = 'create_task'
      auth_token = login(@current_user)
      params = { task: { name: task_name } }
      expect {
        post '/api/v1/tasks', params: params, headers: auth_token
      }.to change(Task, :count).by(+1)

      json = JSON.parse(response.body)
      data = json['data']

      expect(response.status).to eq(200)
      expect(data['name']).to eq(task_name)
    end

    it 'ログインしていない状態でタスクを作成しようとするとエラー' do
      task_name = 'create_task'
      params = { task: { name: task_name } }

      post '/api/v1/tasks', params: params
      json = JSON.parse(response.body)

      expect(response.status).to eq(401)

      expect(json['errors'][0]).to eq(
        'ログインもしくはアカウント登録してください。',
      )
    end

    it 'ログイン状態でタスクを編集' do
      task_name = 'update_task'
      auth_token = login(@current_user)
      task = @current_user.tasks.create(name: 'task')
      params = { task: { name: task_name } }

      put "/api/v1/tasks/#{task.id}", params: params, headers: auth_token

      json = JSON.parse(response.body)
      data = json['data']

      expect(response.status).to eq(200)
      expect(data['name']).to eq(task_name)
    end

    it 'ログインしていない状態でタスクを編集するとエラー' do
      task_name = 'create_task'
      task = @current_user.tasks.create(name: task_name)
      params = { task: { name: task_name } }

      put "/api/v1/tasks/#{task.id}", params: params
      json = JSON.parse(response.body)

      expect(response.status).to eq(401)

      expect(json['errors'][0]).to eq(
        'ログインもしくはアカウント登録してください。',
      )
    end

    it 'ログイン状態でタスクを削除' do
      task_name = 'tasks to be deleted'
      task = @current_user.tasks.create!(name: task_name)
      auth_token = login(@current_user)

      expect {
        delete "/api/v1/tasks/#{task.id}", headers: auth_token
      }.to change(Task, :count).by(-1)

      json = JSON.parse(response.body)
      data = json['data']

      expect(response.status).to eq(200)
      expect(data['name']).to eq(task_name)
    end

    it 'ログインしていない状態でタスクを削除するとエラー' do
      task_name = 'create_task'
      task = @current_user.tasks.create(name: task_name)

      delete "/api/v1/tasks/#{task.id}"
      json = JSON.parse(response.body)

      expect(response.status).to eq(401)

      expect(json['errors'][0]).to eq(
        'ログインもしくはアカウント登録してください。',
      )
    end
  end
end
