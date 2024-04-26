# frozen_string_literal: true

# New user registration action
class UsersController < ApplicationController
  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      flash.now[:succsess] = "ユーザーを登録しました"
      redirect_to user_path
    else
      flash.now[:danger] = "ユーザーの登録に失敗しました"
      rendew :new, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(:user_name, :email, :password, :password_digest, :name, :avatar)
  end
end
