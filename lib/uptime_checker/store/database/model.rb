module UptimeChecker
  module Store
    class Database
      class Status < Sequel::Model(:uptime_checker_statuses)
      end
    end
  end
end
