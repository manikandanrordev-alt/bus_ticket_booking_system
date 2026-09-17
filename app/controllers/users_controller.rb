class UsersController < ApplicationController
  def new
    redirect_to root_path if current_user

    @user = User.new
  end

  def create
    user = User.new(user_params)

    if user.save
      sign_in(user)

      redirect_to root_path, notice: "Account created successfully."
    else
      @user = user

      render :new, status: :unprocessable_content
    end
  end

  private

  def user_params
    params.require(:user).permit(:email)
  end
end