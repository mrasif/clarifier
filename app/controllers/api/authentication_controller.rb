class Api::AuthenticationController < Api::ApiController
  skip_before_action :authenticate, only: :login

  def login
    user = User.find_by_email(auth_params[:email])

    if user && user.authenticate(auth_params[:password])
      session[:user_id] = user.id
      token = JwtAuth.issue({user_id: user.id})
      render_success(:ok, user, meta: { token: token })
    else
      render_error(:unauthorized, ['Unauthorized'])
    end
  end

  def logout
    reset_session
    render_success(:ok, @current_user, links: {related: api_login_path})
  end

  private

  def auth_params
    params.require(:authentication).permit(:email, :password)
  end
end
