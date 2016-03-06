module UptimeChecker
  module Notifier
    class Telegram
      def self.enabled?
        Config.telegram_api_token
      end

      def self.id
        "telegram"
      end

      def self.notify(_subject, message, options)
        require "telegram_bot"
        bot = TelegramBot.new(token: Config.telegram_api_token)

        notification = TelegramBot::OutMessage.new
        notification.chat = TelegramBot::Channel.new(id: options[:telegram])
        notification.text = message
        notification.send_with(bot)
      end
    end
  end
end
