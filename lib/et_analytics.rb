# frozen_string_literal: true

require_relative "et_analytics/version"
require_relative "et_analytics/db_connection"
require_relative "et_analytics/models/user"
require_relative "et_analytics/models/account"
require_relative "et_analytics/models/credit_type"
require_relative "et_analytics/models/debit_type"
require_relative "et_analytics/models/credit"
require_relative "et_analytics/models/debit"
require_relative "et_analytics/analyzers/credit_analyzer"
require_relative "et_analytics/analyzers/debit_analyzer"
require "redis"
require "json"

module EtAnalytics
  class Error < StandardError; end
  def self.root
    File.dirname __dir__
  end

  def self.known_types
    %w(credits_and_debits credit_details debit_details)
  end

  def self.start
    @connection = DbConnection.instance

    redisSubscriber = Redis.new(timeout: 0)
    redisPublisher = Redis.new(timeout: 0)

    redisSubscriber.subscribe('analytics') do |on|
      on.subscribe do |channel, subscriptions|
         puts "Subscribed to ##{channel} (#{subscriptions} subscriptions)"
      end
      on.message do |channel, msg|
         puts "Got message on channel - #{channel}"
         data = JSON.parse(msg)
         puts "#data - #{data}}"
         response = {
           type: data['type'],
           request_key: data['request_key'],
           data: analyzer(data['type']).new(data["account_id"], data["request_key"]).send(data['type'])
         }.to_json
         redisPublisher.publish("analytics_response", response)
      end
    end
  end

  def self.analyzer(type)
    if type.include? "credit"
      return EtAnalytics::Analyzers::CreditAnalyzer
    elsif type.include? "debit"
      return EtAnalytics::Analyzers::DebitAnalyzer
    elsif type.include? "account"
      return EtAnalytics::Analyzers::AccountAnalyzer
    else
      # log error
    end
  end
end
