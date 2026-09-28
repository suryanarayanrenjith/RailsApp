# Be sure to restart your server when you modify this file.

# Define an application-wide content security policy.
# See the Securing Rails Applications Guide for more information:
# https://guides.rubyonrails.org/security.html#content-security-policy-header

Rails.application.configure do
  config.content_security_policy do |policy|
    policy.default_src     :self
    policy.base_uri        :self
    policy.font_src        :self, :data
    policy.form_action     :self
    policy.frame_ancestors :none
    policy.img_src         :self, :data
    policy.object_src      :none
    policy.script_src      :self
    policy.style_src       :self
    # Specify URI for violation reports
    # policy.report_uri "/csp-violation-report-endpoint"
  end

  # Generate session nonces for permitted importmap, inline scripts, and inline styles.
  # The nonce must stay stable for a session because Turbo keeps the first page's
  # policy while it swaps in later pages. It is stored in the session instead of
  # derived from the session id, which is still blank while a first-time visitor's
  # page renders (the session is only written after the action runs).
  config.content_security_policy_nonce_generator = ->(request) { request.session[:content_security_policy_nonce] ||= SecureRandom.base64(16) }
  config.content_security_policy_nonce_directives = %w[script-src style-src]

  # Report violations without enforcing the policy.
  # config.content_security_policy_report_only = true
end
