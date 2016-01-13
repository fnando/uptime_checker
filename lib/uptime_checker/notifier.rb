module UptimeChecker
  module Notifier
    ENABLED_NOTIFIERS = Notifier.constants
      .map {|const| Notifier.const_get(const) }
      .select(&:enabled?)
      .each_with_object({}) {|notifier, buffer| buffer[notifier.id] = notifier }

    COLOR = {up: "green", down: "red"}

    def self.up(config)
      notify(config, :up)
    end

    def self.down(config)
      notify(config, :down)
    end

    def self.notify(config, scope)
      i18n_options = {
        scope: scope,
        name: config["name"],
        url: config["url"],
        time: Time.now.utc
      }

      message, subject = I18n.with_locale(Config.locale) do
        [I18n.t(:message, i18n_options), I18n.t(:subject, i18n_options)]
      end

      color = COLOR[scope]

      config["notify"].each do |options|
        type = options.keys.first
        notifier = ENABLED_NOTIFIERS[type]
        next unless notifier

        UptimeChecker.log notification: type,
                          state: scope,
                          target: options[type]

        options = options.merge(
          "color" => color,
          "url"   => config["url"],
          "state" => scope
        )

        Thread.new { notifier.notify(subject, message, options) }
      end
    end
  end
end
