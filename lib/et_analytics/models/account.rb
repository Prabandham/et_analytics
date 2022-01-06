module EtAnalytics
  module Models
    class Account < ActiveRecord::Base
      belongs_to :user
      has_many :credits
      has_many :debits
    end
  end
end