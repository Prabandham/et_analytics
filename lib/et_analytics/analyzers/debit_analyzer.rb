module EtAnalytics
  module Analyzers
    class DebitAnalyzer
      attr_accessor :account_id, :user_id

      def initialize(account_id, user_id)
        @account_id = account_id
        @user_id = user_id
      end

      def debit_details(days = nil)
        data = EtAnalytics::Models::Debit.includes(:debit_type).
                 where(user_id: @user_id).
                 group_by(&:debit_type).
                 map do |type, values|
                  [type.name, values.map(&:amount).sum]
                 end
        data.push(["Type", "Amount"])
        data.reverse
      end

      def past_seven_day
        account.debits.where(created_at: [7.days.ago..Date.today])
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
