FactoryBot.define do
  factory :user do #factory :testuser, class: User do のようにクラスを明示すればモデル名以外のデータも作れます。
    sequence(:nickname) { |n| "test#{n}" }
    sequence(:email) { |n| "TEST#{n}@example.com" }
    password { 'password' }
    job_id { 1 }
  end

  factory :user2, class: User do
    nickname { 'nickname' }
    email { 'email@email.com' }
    password { 'password' }
  end
end
