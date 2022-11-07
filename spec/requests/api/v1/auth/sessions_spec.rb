require 'rails_helper'

RSpec.describe "Api::V1::Auth::Sessions", type: :request do
  let(:valid_login_params) { { email: 'user1@email.com', password: 'password' } }
  let(:invalid_login_params) { { email: '', password: '' } }

  before do
    ActionMailer::Base.deliveries.clear
    create(:user1)
    create(:test_login_user1)
    create(:test_login_user2)
    create(:test_login_user3)
  end
  describe 'POST #create' do

    context 'パラメータが妥当な場合' do
      it 'リクエストが成功すること' do
        post user_session_path, params: valid_login_params
        expect(response.status).to eq 200
      end
    end

    context 'パラメータが不正の場合' do
      it 'リクエストが失敗すること' do
        post user_session_path, params: invalid_login_params
        expect(response.status).to eq 401
      end

      it 'エラーが表示されること' do
        post user_session_path, params: invalid_login_params
        hash_response_body = JSON.parse(response.body)
        expect(hash_response_body["errors"]).to include "ログイン用の認証情報が正しくありません。再度お試しください。"
      end
    end
  end

  describe "test_login" do
    it "リクエストが成功すること" do
      post api_v1_auth_test_login_path
      expect(response.status).to eq 200
    end

    it "最終ログインが一番遠いユーザでログインされているか" do

      # テストログインユーザーの中で、ログインしたことがあるユーザーがない場合、current_sign_in_atがnilのテストログインユーザーでログインする
      post api_v1_auth_test_login_path
      hash_response_body = JSON.parse(response.body)
      email1 =  hash_response_body["data"]["email"]
      # STDOUT.puts email1
      # STDOUT.puts
      sleep 1
      post api_v1_auth_test_login_path
      hash_response_body = JSON.parse(response.body)
      email2 =  hash_response_body["data"]["email"]
      # STDOUT.puts email2
      # STDOUT.puts
      sleep 1
      post api_v1_auth_test_login_path
      hash_response_body = JSON.parse(response.body)
      email3 =  hash_response_body["data"]["email"]
      # STDOUT.puts email3
      # STDOUT.puts
      sleep 1

      # テストログインユーザーの中で最後にログインが一番遠いユーザでログインする
      post api_v1_auth_test_login_path
      hash_response_body = JSON.parse(response.body)
      # STDOUT.puts hash_response_body
      # STDOUT.puts User.find_by(email: email1).current_sign_in_at
      # STDOUT.puts
      expect(hash_response_body["data"]["email"]).to eq email1

      post api_v1_auth_test_login_path
      hash_response_body = JSON.parse(response.body)
      # STDOUT.puts hash_response_body
      # STDOUT.puts User.find_by(email: email2).current_sign_in_at
      # STDOUT.puts
      expect(hash_response_body["data"]["email"]).to eq email2

      post api_v1_auth_test_login_path
      hash_response_body = JSON.parse(response.body)
      # STDOUT.puts User.find_by(email: email3).current_sign_in_at
      # STDOUT.puts hash_response_body
      # STDOUT.puts
      expect(hash_response_body["data"]["email"]).to eq email3
    end
  end
end
