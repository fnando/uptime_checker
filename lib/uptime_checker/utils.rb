module UptimeChecker
  module Utils
    def self.symbolize_keys(hash)
      hash.each_with_object({}) do |(k, v), target|
        target[k.to_sym] = v
      end
    end

    def self.relative_time(from_time, to_time)
      translate = lambda do |count, scope|
        I18n.with_locale(Config.locale) do
          I18n.t(scope, count: count)
        end
      end

      seconds = (to_time - from_time).to_i
      return translate.call(seconds, "second") if seconds < 60

      minutes = (seconds / 60).to_i
      return translate.call(minutes, "minute") if minutes < 60

      hours = (minutes / 60).to_i
      return translate.call(hours, "hour") if hours < 24

      days = (hours / 24).to_i
      translate.call(days, "day")
    end
  end
end
