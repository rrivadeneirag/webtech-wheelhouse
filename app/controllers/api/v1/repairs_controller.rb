module Api
  module V1
    class RepairsController < BaseController
      # The whole resource is private: the accounting program reads it with a token.
      before_action :authenticate_token!

      # GET /api/v1/repairs — ordered by a model scope, optionally filtered by
      # state. The filter is checked against the enum (no state name is a string
      # literal here); an unknown value answers 400 listing the states that exist.
      # A fixed number of queries, whatever the number of repairs, lines and services.
      def index
        repairs = Repair.newest_first
                        .includes(bike: :customer, repair_services: :service)

        if params[:state].present?
          unless Repair.statuses.key?(params[:state])
            return render_errors(
              ["state must be one of: #{Repair.statuses.keys.join(', ')}"],
              :bad_request
            )
          end
          repairs = repairs.where(status: params[:state])
        end

        render json: repairs.map { |repair| repair_document(repair) }
      end

      # GET /api/v1/repairs/:id
      def show
        repair = Repair.includes(bike: :customer, repair_services: :service).find(params[:id])
        render json: repair_document(repair)
      end

      private

      # Built key by key. No foreign key leaves the API — a program wants the
      # bike and the customer inside, not bike_id or mechanic_id. The customer's
      # phone, the mechanic and the bike's colour are left out: the accounting
      # program does not need them (see docs/api.md). Prices travel as strings.
      def repair_document(repair)
        {
          id: repair.id,
          state: repair.status,
          received_on: repair.received_at&.to_date&.iso8601,
          promised_on: repair.promised_on&.iso8601,
          handed_back_on: repair.handed_back_at&.to_date&.iso8601,
          bike: {
            make_model: repair.bike.make_model,
            serial_number: repair.bike.serial_number
          },
          customer: {
            name: repair.bike.customer.name
          },
          lines: repair.repair_services.map do |line|
            { service: line.service.name, charged: money(line.charged_price) }
          end,
          total: money(repair.total),
          overdue: repair.overdue?,
          customer_answer: customer_answer(repair)
        }
      end

      def money(amount)
        format("%.2f", amount)
      end

      # The customer's answer to the quote, as the lifecycle names it: a repair
      # that was declined reads "Declined"; one the shop has moved past approval
      # reads "Approved"; one still being received or assessed has not answered
      # yet, so it is null. Uses the enum's predicates, not state-name literals.
      def customer_answer(repair)
        return "Declined" if repair.declined?
        return "Approved" if repair.approved? || repair.in_progress? || repair.ready? || repair.collected?

        nil
      end
    end
  end
end
