require "rails_helper"

RSpec.describe "User registration", type: :request do
  describe "POST /signup" do
    context "with valid email" do
      it "creates a user and signs them in" do
        expect {
          post signup_path, params: {
            user: { email: "mani@example.com" }
          }
        }.to change(User, :count).by(1)

        user = User.last

        expect(response).to redirect_to(root_path)
        expect(session[:user_id]).to eq(user.id)
      end
    end

    context "with an existing email" do
      it "does not create a duplicate user" do
        create(:user, email: "mani@example.com")

        expect {
          post signup_path, params: {
            user: { email: "mani@example.com" }
          }
        }.not_to change(User, :count)

        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end
end