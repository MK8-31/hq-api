class Api::V1::Auth::SessionsController < DeviseTokenAuth::SessionsController
  def test_login
    # ログインしていないテストユーザーか最終ログインが一番遠いユーザーを取得
    @resource = User.where(test_login: true).order(Arel.sql("current_sign_in_at IS NOT NULL, current_sign_in_at ASC")).first
    Rails.logger.info @resource

    create_and_assign_token

    sign_in(:user, @resource, store: false, bypass: false)

    render_create_success
  end
end
