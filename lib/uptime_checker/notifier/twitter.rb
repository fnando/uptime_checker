module UptimeChecker
  module Notifier
    class Twitter
      def self.enabled?
        Config.twitter_consumer_key && Config.twitter_consumer_secret
      end

      def self.id
        "twitter"
      end

      def self.notify(subject, message, options)
        require "twitter"

        client = ::Twitter::REST::Client.new do |config|
          config.consumer_key        = Config.twitter_consumer_key
          config.consumer_secret     = Config.twitter_consumer_secret
          config.access_token        = Config.twitter_access_token
          config.access_token_secret = Config.twitter_access_secret
        end

        client.create_direct_message(options["twitter"], message)
      end
    end
  end
end
