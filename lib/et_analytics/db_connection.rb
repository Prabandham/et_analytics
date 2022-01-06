require 'yaml'
require 'active_record'

module EtAnalytics
  class DbConnection
    attr_reader :connection

    @instance_mutex = Mutex.new

    def initialize(value)
      @connection = value
    end

    def self.instance
      return @connection if @connection

      @instance_mutex.synchronize do
        @connection ||= new(
          ActiveRecord::Base.establish_connection(
            adapter: ENV.fetch('DB_ADAPTER', 'postgresql'),
            host: '127.0.0.1',
            username: ENV.fetch('DB_USER', 'prabandham'),
            password: ENV.fetch('DB_PASSWORD', ''),
            database: ENV.fetch('DB_NAME', 'expense_tracker'),
          ))
      end
  
      @connection
    end
  end
end