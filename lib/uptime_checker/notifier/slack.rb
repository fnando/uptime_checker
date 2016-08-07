module UptimeChecker
  module Notifier
    class Slack
      COLORS = {
        "green" => "good",
        "red" => "danger",
        "orange" => "warning"
      }

      def self.enabled?
        Config.slack_api_token
      end

      def self.id
        "slack" || "slack_customer"
      end

      def self.notify(subject, message, options)
        duration = Time.current - options[:ptime]

       if options[:state] == :up || options[:state] == :down
        channel = options[:slack]['main_c']
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

       if options[:state] == :warning || options[:state] == :up && duration >= 5.minutes
          channel = options[:slack]['secondary_c']
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
end
