require "bundler/setup"
require "env_vars/dotenv"
require "aitch"
require "i18n"
require "redis"
require "active_support/time"

require "erb"
require "yaml"

def require_dir(dir)
  Dir["#{dir}/**/*.rb"].sort.each do |file|
    require file
  end
end

require_dir "#{__dir__}/uptime_checker/notifier"
require_dir "#{__dir__}"

module UptimeChecker
  def self.log(options)
    options[:time] ||= Time.current.iso8601
    message = options
      .each_with_object([]) {|(k, v), b| b << "#{k}=#{v.to_s.inspect}" }
      .join(" ")

    puts message
  end
end

$stdout.sync = true

I18n.load_path += Dir["#{__dir__}/uptime_checker/locales/**/*.yml"]
I18n.default_locale = :en
I18n.locale = UptimeChecker::Config.locale
Time.zone = UptimeChecker::Config.timezone
Thread.abort_on_exception = UptimeChecker::Config.abort_thread_on_exception?

UptimeChecker.log locale: I18n.locale,
                  timezone: Time.zone.name,
                  enabled_notifiers: UptimeChecker::Notifier::ENABLED_NOTIFIERS.keys.join(", ")

UptimeChecker.run
