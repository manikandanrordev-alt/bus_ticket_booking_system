require "rails_helper"

RSpec.describe "Home", type: :request do
  describe "GET /" do
    it "returns a successful response for an authenticated user" do
      user = create(:user)

      post login_path, params: { email: user.email }

      get root_path

      expect(response).to have_http_status(:ok)
    end

    it "redirects unauthenticated users to login" do
      get root_path

      expect(response).to redirect_to(login_path)
    end
  end
end