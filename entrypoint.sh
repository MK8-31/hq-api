#!/bin/bash
set -e

# Remove a potentially pre-existing server.pid for Rails.
rm -f /app/tmp/pids/server.pid

# Nginxの起動
sudo service nginx start
# Railsのセットアップ
cd /app
bin/setup # アプリケーションを初期化するスクリプトがある
# pumaの起動
bundle exec pumactl start

# Then exec the container's main process (what's set as CMD in the Dockerfile).
exec "$@"
