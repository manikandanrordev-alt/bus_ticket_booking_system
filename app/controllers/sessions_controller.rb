class SessionsController < ApplicationController
  def new
    redirect_to root_path if current_user
  end

  def create
    user = User.find_by(email: normalized_email)

    if user
      sign_in(user)

      redirect_to root_path, notice: "Welcome back."
    else
      flash.now[:alert] = "No account found with that email."
      render :new, status: :unprocessable_content
    end
  end

  def destroy
    sign_out

    redirect_to login_path, notice: "You have been signed out."
  end

  private

  def normalized_email
    params[:email].to_s.strip.downcase
  end
end