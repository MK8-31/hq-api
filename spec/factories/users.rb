FactoryBot.define do
  factory :user do #factory :testuser, class: User do のようにクラスを明示すればモデル名以外のデータも作れます。
    sequence(:nickname) { |n| "test#{n}" }
    sequence(:email) { |n| "TEST#{n}@example.com" }
    password { 'password' }
    job_id { 1 }
  end

  factory :user1, class: User do
    nickname { 'nickname1' }
    email { 'user1@email.com' }
    password { 'password' }
  end

  factory :user2, class: User do
    nickname { 'nickname2' }
    email { 'user2@email.com' }
    password { 'password' }
  end

  factory :test_login_user1, class: User do
    nickname { 'test_login_user1' }
    email { 'test_login_user1@email.com' }
    password { 'password' }
    test_login { true }
  end

  factory :test_login_user2, class: User do
    nickname { 'test_login_user2' }
    email { 'test_login_user2@email.com' }
    password { 'password' }
    test_login { true }
  end

  factory :test_login_user3, class: User do
    nickname { 'test_login_user3' }
    email { 'test_login_user3@email.com' }
    password { 'password' }
    test_login { true }
  end
end
