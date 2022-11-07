namespace :users do
  desc 'ユーザを追加で作成するなどの処理を記述'

  task :create_test_login_users => :environment do
    begin
      ApplicationRecord.transaction do
        20.times do |n|
          nickname = "テストユーザ#{n + 1}"
          email = "testuser-#{n + 1}@example.com"
          password = 'password'
          User.create!(
            nickname: nickname,
            email: email,
            password: password,
            password_confirmation: password,
            test_login: true
          )
        end

        task_list = ["腕立て10回", "背筋10回", "読書10分", "競プロ一問", "腹筋10回", "瞑想5分", "早寝", "ランニング10分"]

        # 負荷がかからないようにレコードを3件ずつ取得して処理
        User.where(test_login: true).find_each(batch_size: 3) do |user|
          8.times do |n|
            user.tasks.create!(name: task_list[n])
          end
        end
      end
    rescue => exception
      puts exception
    end
  end
end
