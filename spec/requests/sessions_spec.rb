require "rails_helper"

RSpec.describe "User sessions", type: :request do
  describe "POST /login" do
    context "when the user exists" do
      it "signs the user in" do
        user = create(:user, email: "mani@example.com")

        post login_path, params: {
          email: "mani@example.com"
        }

        expect(response).to redirect_to(root_path)
        expect(session[:user_id]).to eq(user.id)
      end
    end

    context "when the user does not exist" do
      it "does not authenticate the request" do
        post login_path, params: {
          email: "unknown@example.com"
        }

        expect(response).to have_http_status(:unprocessable_content)
        expect(session[:user_id]).to be_nil
      end
    end
  end

  describe "DELETE /logout" do
    it "clears the current session" do
      user = create(:user)

      post login_path, params: {
        email: user.email
      }

      expect(session[:user_id]).to eq(user.id)

      delete logout_path

      expect(response).to redirect_to(login_path)
      expect(session[:user_id]).to be_nil
    end
  end
end