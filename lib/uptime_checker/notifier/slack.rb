module UptimeChecker
  module Notifier
    class Slack
      COLORS = {
        "green" => "good",
        "red" => "danger"
      }

      def self.enabled?
        Config.slack_api_token
      end

      def self.id
        "slack"
      end

      def self.notify(subject, message, options)
        channel = options[:slack]
        color = COLORS[options[:color]]

        params = {
          token: Config.slack_api_token,
          text: "",
          channel: channel,
          attachments: JSON.dump([{
            fallback: message,
            title: subject,
            text: message,
            color: color
          }])
        }

        HttpClient.post("https://slack.com/api/chat.postMessage", params)
      end
    end
  end
end
