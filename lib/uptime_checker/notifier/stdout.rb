module UptimeChecker
  module Notifier
    class Stdout
      def self.enabled?
        true
      end

      def self.id
        "stdout"
      end

      def self.notify(subject, message, *)
        UptimeChecker.log subject: subject, message: message
      end
    end
  end
end
