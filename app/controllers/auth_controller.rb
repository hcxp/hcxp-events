class AuthController < ApplicationController
  def discourse
    sso = SsoWithDiscourse::Sso.new
    sso.return_url = auth_comeback_discourse_url
    session[:sso] = sso

    redirect_to sso.request_url
  end
end
