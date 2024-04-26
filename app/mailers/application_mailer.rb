# frozen_string_literal: true

# action to send email
class ApplicationMailer < ActionMailer::Base
  default from: "from@example.com"
  layout "mailer"
end
