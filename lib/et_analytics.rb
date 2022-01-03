# frozen_string_literal: true

require_relative "et_analytics/version"
require_relative "et_analytics/db_connection"
require_relative "et_analytics/models/user"
require "redis"

module EtAnalytics
  class Error < StandardError; end
  class << self
    attr_accessor :connection

    def initialize
      @connection = DbConnection.instance
    end
  end

  def init
    @connection ||= DbConnection.instance
  end

  def self.root
    File.dirname __dir__
  end

  def self.start
    redis = Redis.new(:timeout => 0)

    redis.subscribe('analytics') do |on|
      on.subscribe do |channel, subscriptions|
         puts "Subscribed to ##{channel} (#{subscriptions} subscriptions)"
      end
      on.message do |channel, msg|
         data = JSON.parse(msg)
         puts "##{channel} - [#{data['user']}]: #{data['msg']}"
      end
    end
  end
end
