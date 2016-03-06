module UptimeChecker
  module Notifier
    class Email
      def self.enabled?
        Config.sendgrid_username &&
          Config.sendgrid_password
      end

      def self.id
        "email"
      end

      def self.notify(subject, message, options)
        require "mail"

        Mail.defaults do
          delivery_method :smtp,
                          address: "smtp.sendgrid.net",
                          port: 587,
                          user_name: Config.sendgrid_username,
                          password: Config.sendgrid_password,
                          domain: "heroku.com",
                          authentication: :plain,
                          enable_starttls_auto: true
        end

        Mail.deliver do
          subject(subject)
          body(message)
          to(options[:email])
          from("UptimeChecker <noreply@uptimechecker>")
        end
      end
    end
  end
end
