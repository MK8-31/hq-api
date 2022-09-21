require 'rails_helper'

RSpec.describe 'Api::V1::Auth::Registrations', type: :request do
  let(:user) { create(:user) }
  let(:user_params) { attributes_for(:user) }
  let(:invalid_user_params) { attributes_for(:user, nickname: '') }

  describe 'POST #create' do
    before { ActionMailer::Base.deliveries.clear }

    context 'パラメータが妥当な場合' do
      it 'リクエストが成功すること' do
        # STDOUT.puts("user_params: #{user_params}")

        # post api_v1_user_registration_path, params: user_params
        post api_v1_user_registration_path,
             params: {
               nickname: 'hoge',
               email: 'hoge@hoge.hoge.com',
               password: 'hogehoge',
             }

        # STDOUT.puts(response.body)
        # STDOUT.puts(response.header)
        expect(response.status).to eq 200
      end

      # it '認証メールが送信されること' do
      #   post api_v1_user_registration_path, params: user_params
      #   expect(ActionMailer::Base.deliveries.size).to eq 1
      # end

      it 'createが成功すること' do
        expect do
          post api_v1_user_registration_path, params: user_params
        end.to change(User, :count).by 1
      end

      # it 'リダイレクトされること' do
      #   post api_v1_user_registration_path, params: user_params
      #   expect(response).to redirect_to 'http://localhost:3000'
      # end
    end

    #   it 'ユーザーが一人増えること' do
    #     expect do
    #       post api_v1_user_registration_path, params: user_params
    #     end.to change(User, :count).by 1
    #   end
    # end

    # context 'パラメータが不正の場合' do
    #   it 'リクエストが失敗すること' do
    #     post api_v1_user_registration_path, params: invalid_user_params
    #     expect(response.status).to eq 422
    #   end

    #   it 'ユーザーが増えないこと' do
    #     expect do
    #       post api_v1_user_registration_path, params: invalid_user_params
    #     end.to change(User, :count).by 0
    #   end

    #   it 'エラーが表示されること' do
    #     post api_v1_user_registration_path, params: invalid_user_params
    #     # STDOUT.puts(response.body)
    #     expect(response.body).to include "Nickname can't be blank"
    #   end
    # end
  end
end
