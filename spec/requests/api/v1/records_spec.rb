require 'rails_helper'

RSpec.describe 'Api::V1::Records', type: :request do
  before do
    @current_user = create(:user)
    @job = create(:warrior)
    @current_user.update(job_id: @job.id)
  end

  describe 'GET /show' do
    it 'ログイン状態で記録を取得(記録がない状態)' do
      auth_token = login(@current_user)
      expect(get '/api/v1/records/show', headers: auth_token).to eq(200)
      json = JSON.parse(response.body)
      data = json['data']

      # STDOUT.puts data
      expect(data['job_id']).to eq(@current_user.job_id)
    end

    it 'ログイン状態で記録を取得(記録がある状態)' do
      record = @current_user.records.create!(job_id: @job.id)
      auth_token = login(@current_user)
      expect(get '/api/v1/records/show', headers: auth_token).to eq(200)
      json = JSON.parse(response.body)
      data = json['data']

      # STDOUT puts data
      expect(data['id']).to eq(record.id)
    end

    it 'ログインしないで記録を取得' do
      expect(get '/api/v1/records/show').not_to eq(200)
    end
  end
end
