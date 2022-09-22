FROM ruby:3.1.1
# ベースにするイメージを指定

RUN apt-get update -qq && apt-get install -y build-essential libpq-dev nodejs default-mysql-client vim
# RailsのインストールやMySQLへの接続に必要なパッケージをインストール

########################################################################
# yarnパッケージ管理ツールをインストール
RUN apt-get update && apt-get install -y curl apt-transport-https wget && \
curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list && \
apt-get update && apt-get install -y yarn
#######################################################################

RUN apt install git

# 本番環境用
# -y	問い合わせがあった場合はすべて「y」と答える
RUN apt-get install -y sudo nginx

# appディレクトリを作業用ディレクトリとして設定(appディレクトリは自動で作成される)
WORKDIR /app

# ローカルの Gemfile と Gemfile.lock をコンテナ内のapp配下にコピー
COPY Gemfile /app/Gemfile
COPY Gemfile.lock /app/Gemfile.lock

# コンテナ内にコピーした Gemfile の bundle install
RUN bundle install

# ローカルのapp配下のファイルをコンテナ内のapp配下にコピー
COPY . /app


RUN mkdir -p tmp/sockets
RUN mkdir tmp/pids

# for dev
# COPY dev.sh /usr/bin/
# RUN chmod +x /usr/bin/dev.sh
# ENTRYPOINT ["dev.sh"]
# EXPOSE 3000
# # Configure the main process to run when running the image
# CMD ["rails", "server", "-b", "0.0.0.0"]

# # nginx
# groupaddコマンドで新しいグループを作成
RUN groupadd nginx
# useraddコマンドで新しいユーザーを作成
# -g, --gid GROUP プライマリグループのグループ名かグループIDを指定
RUN useradd -g nginx nginx
ADD nginx/nginx.conf /etc/nginx/nginx.conf

# 以下を追加 for gcp cloud run
COPY start.sh /usr/bin/
RUN chmod +x /usr/bin/start.sh
ENTRYPOINT ["start.sh"]
EXPOSE 80

CMD ["bin/start"]


# docker-compose run web rails new . --webpack=vue --force --database=mysql --skip-bundle
# docker-compose run web rails new . --force --database=mysql --skip-bundle
# docker-compose build
# database.yml を編集
# username: root password: docker-composeのやつ host: db
# docker-compose run rails webpacker:install
# docker-compose up
# docker-compose exec web rails db:create

# mbp@oonomikihitonoMacBook-Pro ~ % ./cloud_sql_proxy -dir /Users/mbp/Documents/gcp/cloudsql
