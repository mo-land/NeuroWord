require 'rails_helper'

RSpec.describe "/XXXXX", type: :request do
  describe 'GET /XXXXX' do
    before do
      # https://github.com/omniauth/omniauth/wiki/Integration-Testing
      Rails.application.env_config["devise.mapping"] = Devise.mappings[:user]
      Rails.application.env_config["omniauth.auth"] = OmniAuth.config.mock_auth[:google_oauth2]
      # 認証のパス
      get '/users/auth/google_oauth2/callback', params: { provider: "google_oauth2" }
    end

    it 'Google OAuth2認証が成功し、ルートパスにリダイレクトされること' do
      expect(response).to have_http_status(302)
      expect(response).to redirect_to(root_path) # または適切なパス
    end

    it 'ユーザーがログイン状態になること' do
      expect(controller.current_user).to be_present
      expect(controller.current_user.email).to eq('john@example.com')
      expect(controller.current_user.name).to eq('john')
    end

    it 'SnsCredentialが作成されること' do
      sns_credential = SnsCredential.find_by(uid: '12345abcde', provider: 'google_oauth2')
      expect(sns_credential).to be_present
      expect(sns_credential.provider).to eq('google_oauth2')
      expect(sns_credential.uid).to eq('12345abcde')
    end
  end
end
