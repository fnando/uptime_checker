module UptimeChecker
  module Store
    class Redis
      def connect!
      end

      def connection
        @connection ||= ::Redis.new
      end

      def get(key)
        data = connection.get(key)
        data && Utils.symbolize_keys(JSON.load(data))
      end

      def set(key, value)
        connection.set(key, value.to_json)
      end

      def exist?(key)
        connection.exists(key)
      end
    end
  end
end
