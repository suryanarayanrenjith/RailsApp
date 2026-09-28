class ApplicationMailer < ActionMailer::Base
  default from: ENV.fetch("MAILER_FROM", "RailsApp <no-reply@example.com>")
  layout "mailer"
end
