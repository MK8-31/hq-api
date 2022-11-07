require 'rails_helper'

RSpec.describe 'Api::V1::Auth::Registrations', type: :request do
  let(:user_params) { attributes_for(:user1) }
  let(:invalid_user_params) { attributes_for(:user, nickname: '') }
  let(:duplicate_user_params) { attributes_for(:user2)}

  describe 'POST #create' do
    before do
      ActionMailer::Base.deliveries.clear
      create(:user2)
    end

    context 'パラメータが妥当な場合' do
      it 'リクエストが成功すること' do
        # STDOUT.puts("user_params: #{user_params}")

        # post api_v1_user_registration_path, params: user_params
        post user_registration_path,
             params: {
               nickname: 'hoge',
               email: 'hoge@hoge.hoge.com',
               password: 'hogehoge',
             }

        # STDOUT.puts(response.body)
        # STDOUT.puts(response.header)
        expect(response.status).to eq 200
      end

      it 'createが成功すること' do
        expect do
          post user_registration_path, params: user_params
        end.to change(User, :count).by 1
      end
    end

    context 'パラメータが不正の場合' do
      it 'リクエストが失敗すること' do
        post user_registration_path, params: invalid_user_params
        expect(response.status).to eq 422
      end

      it 'ユーザーが増えないこと' do
        expect do
          post user_registration_path, params: invalid_user_params
        end.to change(User, :count).by 0
      end

      it 'エラーが表示されること' do
        post user_registration_path, params: invalid_user_params
        hash_response_body = JSON.parse(response.body)
        # STDOUT.puts(hash_response_body["errors"])
        # STDOUT.puts(hash_response_body["errors"]["full_messages"])
        expect(hash_response_body["errors"]["full_messages"]).to include "Nicknameを入力してください"
      end

      it '重複している場合、ユーザーが増えないこと' do
        expect do
          post user_registration_path, params: duplicate_user_params
        end.to change(User, :count).by 0
      end
    end
  end
end
