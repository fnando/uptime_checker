module UptimeChecker
  module Store
    class Database
      require "sequel"

      def connect!
        connection = Sequel.connect(Config.database_url)
        connection.extension :pg_json
        require_relative "./database/model"
      end

      def get(key)
        data = Status.where(key: key).first&.data
        data && Utils.symbolize_keys(data)
      end

      def set(key, value)
        status = Status.where(key: key).first || Status.new
        status.key = key
        status.data = value
        status.save
      end

      def exist?(key)
        Status.where(key: key).first.present?
      end
    end
  end
end
