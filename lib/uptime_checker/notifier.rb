require 'logger'

module UptimeChecker
  module Notifier
    ENABLED_NOTIFIERS = Notifier.constants
      .map {|const| Notifier.const_get(const) }
      .select(&:enabled?)
      .each_with_object({}) {|notifier, buffer| buffer[notifier.id] = notifier }

    COLOR = {up: "green", down: "red", warning: "orange"}

    def self.up(config, transition)
      config[:duration] = Utils.relative_time(transition.previous.time, transition.current.time)
      config[:changed_at] = transition.previous.time
      config[:time] = transition.current.time
      notify(config, :up)
    end

    def self.down(config, transition)
      config[:changed_at] = transition.time
      notify(config, :down)
    end

    def self.warning(config, transition)
      config[:changed_at] = transition.previous.time
      config[:duration] = transition.current.time - transition.previous.time
      notify(config, :warning)
    end

    def self.logger
      @logger ||= Logger.new("./log/error.log", 10)
    end

    def self.notify(config, scope)
      config = Utils.symbolize_keys(config)

      i18n_options = {
        scope: scope,
        time: Time.current
      }.merge(config)

      message, subject = I18n.with_locale(Config.locale) do
        [I18n.t(:message, i18n_options), I18n.t(:subject, i18n_options)]
      end

      color = COLOR[scope]

      config[:notify].flatten.each do |options|
        type = options.keys.first
        notifier = ENABLED_NOTIFIERS[type]
        next unless notifier

        UptimeChecker.log notification: type,
                          state: scope,
                          target: options[type]

        options = options.merge(
          color: color,
          url: config[:url],
          state: scope,
          ptime: config[:changed_at],
          name: config[:name]
        )

        Thread.new do
          begin
            notifier.notify(subject, message, Utils.symbolize_keys(options))
          rescue => e
            logger.error e
          end
        end
      end
    end

  end
end
