module UptimeChecker
  module Notifier
    class Hipchat
      def self.enabled?
        Config.hipchat_api_token
      end

      def self.id
        "hipchat"
      end

      def self.notify(subject, message, options)
        room_id = options["hipchat"]
        endpoint = "https://api.hipchat.com/v2/room/#{room_id}/notification"
        HttpClient.post(endpoint,
                        message_format: "text",
                        color: options["color"],
                        notify: true,
                        message: message,
                        title: subject,
                        auth_token: Config.hipchat_api_token).body
      end
    end
  end
end
