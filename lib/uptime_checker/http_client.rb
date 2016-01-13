module UptimeChecker
  HttpClient = Aitch::Namespace.new

  HttpClient.configure do |config|
    config.user_agent = "UptimeChecker (https://github.com/fnando/uptime_checker)"
  end
end
