# frozen_string_literal: true

# ユーザーの新規登録ログイン時のバリデーション設定
class User < ApplicationRecord
  authenticates_with_sorcery!

  validates :user_name, presence: true, length: { maximum: 16 }
  validates :email, presence: true, uniqueness: true, format: { with: /\A\S+@\S+\.\S+\z/, message: "is not valid" }
  validates :name, presence: true, length: { maximum: 8 }, uniqueness: true
  validates :avatar, format: { with: /\.(png|jpg|jpeg)\z/i, message: "must be a valid image format" }
  validates :password, length: { minimum: 8 }
  validates :password_confirmation, presence: true, on: :create
  validate :password_complexity

  private

  # パスワードの複雑さを検証するメソッドをリファクタリング
  def password_complexity
    return if password_meets_criteria?

    errors.add :password,
               "must include at least one lowercase letter, one uppercase letter, one digit, and one special character"
  end

  # パスワードが複雑性の基準を満たしているかどうかを判定
  def password_meets_criteria?
    regex = %r{
      \A
      (?=.*[a-z])            # 少なくとも一つの小文字が必要
      (?=.*[A-Z])            # 少なくとも一つの大文字が必要
      (?=.*\d)               # 少なくとも一つの数字が必要
      (?=.*[!@#$%^&*()_+{}\[\]:"';?/>.<,]) # 少なくとも一つの特殊文字が必要
      [A-Za-z\d!@#$%^&*()_+{}\[\]:"';?/>.<,]{8,} # 全体の長さは最低8文字
      \z
    }x
    password.present? && password.match(regex)
  end
end
