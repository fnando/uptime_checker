module UptimeChecker
  Config = Env::Vars.new do
    optional :config_file, string, File.join(Dir.pwd, "checkers.yml")
    optional :abort_thread_on_exception, bool, false
    optional :interval, int, 30
    optional :locale, string, "en"
    optional :timezone, string, "Etc/UTC"
    optional :uptime_checker_store, string, "redis"
    optional :database_url, string, ""

    optional :twitter_consumer_key, string, nil
    optional :twitter_consumer_secret, string, nil
    optional :twitter_access_token, string, nil
    optional :twitter_access_secret, string, nil

    optional :telegram_api_token, string, nil

    optional :sendgrid_username, string, nil
    optional :sendgrid_password, string, nil

    optional :hipchat_api_token, string, nil
    optional :noti_api_token, string, nil

    optional :slack_api_token, string, nil
    optional :pushover_application_token, string, nil

    optional :campfire_api_token, string, nil
    optional :campfire_subdomain, string, nil

    property :redis, -> { Redis.new }

    property :store_adapter, -> {
      case uptime_checker_store
      when "redis"
        require_relative "./store/redis"
        Store::Redis
      when "database"
        require_relative "./store/database"
        Store::Database
      else
        fail "invalid uptime store"
      end
    }
  end
end
