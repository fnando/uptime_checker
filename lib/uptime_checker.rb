require "bundler/setup"
require "env_vars/dotenv"
require "aitch"
require "i18n"
require "redis"

require "erb"
require "yaml"

def require_dir(dir)
  Dir["#{dir}/**/*.rb"].each do |file|
    require file
  end
end

require_dir "#{__dir__}/uptime_checker/notifier"
require_dir "#{__dir__}"

module UptimeChecker
  def self.log(options)
    options[:time] ||= Time.now.utc.iso8601
    message = options
      .each_with_object([]) {|(k, v), b| b << "#{k}=#{v.to_s.inspect}" }
      .join(" ")

    puts message
  end
end

I18n.load_path += Dir["#{__dir__}/uptime_checker/locales/**/*.yml"]
Thread.abort_on_exception = UptimeChecker::Config.abort_thread_on_exception?
$stdout.sync = true

UptimeChecker.run
