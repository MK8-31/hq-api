#!/bin/bash
set -e

RAILS_PORT=80
if [ -n "$PORT" ]; then
  RAILS_PORT=$PORT
fi

# # migration
bin/rails db:migrate RAILS_ENV=production
# bin/rails db:migrate:reset DISABLE_DATABASE_ENVIRONMENT_CHECK=1
# bin/rails db:seed RAILS_ENV=production
# # assets precompile
# bundle exec rake assets:precompile RAILS_ENV=production

# テストログインユーザを追加
bin/rails users:create_test_login_users

# Remove a potentially pre-existing server.pid for Rails.
rm -f tmp/pids/server.pid

# bin/rails s -p $RAILS_PORT -b 0.0.0.0

cd /app
# bin/setup # アプリケーションを初期化するスクリプトがある
# pumaの起動
# bundle exec pumactl start
bundle exec puma -C config/puma.rb

# Nginxの起動
sudo service nginx start
# Railsのセットアップ


# Then exec the container's main process (what's set as CMD in the Dockerfile).
exec "$@"
