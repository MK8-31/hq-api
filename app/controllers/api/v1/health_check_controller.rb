class Api::V1::HealthCheckController < ApplicationController
  def index
    # 応答ステータスとヘッダ情報のみを表示
    # head(ステータスコード, 応答ヘッダ={})
    head 200
  end
end
