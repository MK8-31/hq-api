# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

warrior = Job.create!(name: 'Warrior')

mage = Job.create!(name: 'Mage')

priest = Job.create!(name: 'Priest')

User.create!(
  nickname: 'example',
  email: 'example@example.com',
  password: 'password',
)

# 追加のユーザーをまとめて生成する
20.times do |n|
  nickname = Faker::Name.name
  email = "example-#{n + 1}@example.com"
  password = 'password'
  User.create!(
    nickname: nickname,
    email: email,
    password: password,
    password_confirmation: password,
  )
end

# 負荷がかからないようにレコードを3件ずつ取得して処理
User.find_each(batch_size: 3) do |user|
  8.times do
    task_name = Faker::Lorem.sentence(word_count: 3)
    user.tasks.create!(name: task_name)
  end
end

test_user = User.create!(nickname: 'test', email: 'test@example.com', password: 'password')
test_user.tasks.create!(name: "腕立て10回")
test_user.tasks.create!(name: "背筋10回")
test_user.tasks.create!(name: "読書10分")
test_user.tasks.create!(name: "競プロ一問")
test_user.tasks.create!(name: "腹筋10回")
test_user.tasks.create!(name: "瞑想5分")
test_user.tasks.create!(name: "早寝")
test_user.tasks.create!(name: "早起き")
test_user.tasks.create!(name: "ランニング10分")
