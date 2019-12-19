class AuthComebackController < ApplicationController
  def discourse
    sso = SsoWithDiscourse::Sso.new
    sso.nonce = session[:sso]['nonce']
    sso.parse(params)

    if sso.status == 'success'
      email = sso.user_info[:email]
      user = User.find_by(email: email)

      attrs = {
        email: email
      }

      if user.blank?
        user = User.create!(attrs.merge!(
          active: true,
          approved: true,
          confirmed: true
        ))
      end

      # Create session
      UserSession.new(user).save!

      redirect_to root_path, notice: 'Zalogowano pomyślnie!'
    else
      redirect_to root_path, notice: 'Coś poszło nie tak przy próbie zalogowania. Spróbuj ponownie za chwilę.'
    end
  end
end
