module EtAnalytics
  module Analyzers
    class CreditAnalyzer
      attr_accessor :account_id, :user_id

      def initialize(account_id, user_id)
        @account_id = account_id
        @user_id = user_id
      end

      def credit_details(days = 30)
        data = EtAnalytics::Models::Credit.includes(:credit_type).
                 where(user_id: @user_id).
                 group_by(&:credit_type).
                 map do |credit_type, values|
                  [credit_type.name, values.map(&:amount).sum]
                 end
        data.push(["Type", "Amount"])
        data.reverse
      end

      def past_seven_day
        account.credits.where(created_at: [7.days.ago..Date.today])
      end

      private

      def account
        @account ||= EtAnalytics::Models::Account.find_by(id: @account_id) if @account_id
      end

      def user
        @user ||- EtAnalytics::Models::User.find_by(id: @user_id)
      end
    end
  end
end
