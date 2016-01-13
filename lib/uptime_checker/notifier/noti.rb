module UptimeChecker
  module Notifier
    class Noti
      def self.enabled?
        Config.noti_api_token
      end

      def self.id
        "noti"
      end

      def self.notify(subject, message, options)
        require "noti"
        ::Noti.app = Config.noti_api_token

        notification = ::Noti::Notification.new
        notification.url   = options["url"]
        notification.title = subject
        notification.text  = message
        notification.deliver_to(options["noti"])
      end
    end
  end
end
