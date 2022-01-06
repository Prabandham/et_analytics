require_relative "../db_connection"

module EtAnalytics
  module Models
    class Credit < ActiveRecord::Base
      belongs_to :credit_type
      belongs_to :account
      belongs_to :user
    end
  end
end