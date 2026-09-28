module Authentication
  extend ActiveSupport::Concern

  included do
    before_action :require_authentication
    helper_method :authenticated?
  end

  class_methods do
    # Public actions still resume an existing session so pages can show
    # signed-in visitors their own controls.
    def allow_unauthenticated_access(**options)
      skip_before_action :require_authentication, **options
      before_action :resume_session, **options
    end

    # For pages that only make sense for visitors, like the sign-in form.
    def redirect_authenticated_users(**options)
      before_action -> { redirect_to root_path if authenticated? }, **options
    end
  end

  private
    def authenticated?
      resume_session
    end

    def require_authentication
      resume_session || request_authentication
    end

    def resume_session
      Current.session ||= find_session_by_cookie
    end

    def find_session_by_cookie
      Session.find_by(id: cookies.signed[:session_id]) if cookies.signed[:session_id]
    end

    def request_authentication
      respond_to do |format|
        format.html do
          # Only pages that can be revisited with a GET are worth returning to.
          session[:return_to_after_authenticating] = request.url if request.get? || request.head?
          redirect_to new_session_path, alert: "Please sign in to continue."
        end
        format.any { head :unauthorized }
      end
    end

    def after_authentication_url
      session.delete(:return_to_after_authenticating) || root_url
    end

    def start_new_session_for(user)
      user.sessions.create!(user_agent: request.user_agent, ip_address: request.remote_ip).tap do |session|
        Current.session = session
        cookies.signed.permanent[:session_id] = { value: session.id, httponly: true, same_site: :lax }
      end
    end

    def terminate_session
      Current.session.destroy
      cookies.delete(:session_id)
    end
end
