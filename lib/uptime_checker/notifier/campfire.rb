module UptimeChecker
  module Notifier
    class Campfire
      def self.enabled?
        Config.campfire_api_token
      end

      def self.id
        "campfire"
      end

      def self.notify(subject, message, settings)
        body = {message: {body: message, type: "TextMessage"}}
        endpoint = File.join(
          "https://#{Config.campfire_subdomain}.campfirenow.com/room",
          settings[:campfire].to_s,
          "speak.json"
        )

        HttpClient.post do
          url endpoint
          params body
          headers content_type: "application/json"
          options user: Config.campfire_api_token, password: "x"
        end
      end
    end
  end
end
