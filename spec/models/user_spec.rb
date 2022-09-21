require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'create' do
    it 'ニックネーム、メール、パスワードがある場合、有効である' do
      user = build(:user)
      expect(user.valid?).to eq true
    end

    it 'ニックネームがない場合、無効' do
      user = build(:user, nickname: nil)
      expect(user.valid?).to eq false
    end

    it 'メールがない場合、無効' do
      user = build(:user, email: nil)
      expect(user.valid?).to eq false
    end

    it 'パスワードがない場合、無効' do
      user = build(:user, password: nil)
      expect(user.valid?).to eq false
    end

    it 'ニックネームが重複した場合、無効' do
      user = FactoryBot.create(:user)
      duplicate_user =
        User.new(
          nickname: user.nickname,
          email: 'aaa@aaa.com',
          password: 'password',
        )
      expect(duplicate_user.valid?).to eq false
    end

    it 'メールが重複した場合、無効' do
      user = FactoryBot.create(:user)

      # STDOUT.puts(user.email)
      Rails.logger.info user.email
      duplicate_user =
        User.new(nickname: 'testsss', email: user.email, password: 'password')
      expect(duplicate_user.valid?).to eq false
    end

    it 'パスワードが６文字以下の場合、無効' do
      FactoryBot.create(:user)
      user = User.new(nickname: 'test2', email: 'aaa@aaa.com', password: 'pass')
      expect(user.valid?).to eq false
    end
  end
end
