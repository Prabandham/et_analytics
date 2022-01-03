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
        db_config_path = File.join(EtAnalytics.root, "config/database.yml")
        db_config = YAML.load(File.read(db_config_path))
        @connection ||= new(ActiveRecord::Base.establish_connection(db_config))
      end
  
      @connection
    end
  end
end