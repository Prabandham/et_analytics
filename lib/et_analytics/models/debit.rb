module EtAnalytics
  module Models
    class Debit < ActiveRecord::Base
      belongs_to :debit_type
      belongs_to :account
      belongs_to :user
    end
  end
end