module UptimeChecker
  module Notifier
    class Pushover
      def self.enabled?
        Config.pushover_application_token
      end

      def self.id
        "pushover"
      end

      def self.notify(subject, message, options)
        endpoint = "https://api.pushover.net/1/messages.json"
        HttpClient.post(endpoint,
                        token: Config.pushover_application_token,
                        user: options[:pushover],
                        title: subject,
                        message: message)
      end
    end
  end
end
