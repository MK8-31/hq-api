class Api::V1::Auth::SessionsController < DeviseTokenAuth::SessionsController
  before_action :authenticate_user!, only: %i[get_user_info]

  def test_login
    # ログインしたことがないテストログインユーザーか最終ログインが一番遠いテストログインユーザーを取得
    @resource = User.where(test_login: true).order(Arel.sql("current_sign_in_at IS NOT NULL, current_sign_in_at ASC")).first
    Rails.logger.info @resource

    create_and_assign_token

    sign_in(:user, @resource, store: false, bypass: false)

    render_create_success
  end

  def get_user_info
    # 現在ログイン中のユーザー情報を送信
    render_create_success
  end
end
