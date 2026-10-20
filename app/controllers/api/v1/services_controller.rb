module Api
  module V1
    class ServicesController < BaseController
      # Reading the price list is public; registering a service needs a token.
      before_action :authenticate_token!, only: :create

      # GET /api/v1/services — the public wall list, ordered by a model scope.
      # One query brings every service with how many repairs it was charged on,
      # so the client never asks twice (requirement 7).
      def index
        services = Service.by_name
                          .left_joins(:repair_services)
                          .select("services.*, COUNT(repair_services.id) AS repairs_charged_count")
                          .group("services.id")

        render json: services.map { |service| service_document(service, service.repairs_charged_count) }
      end

      # GET /api/v1/services/:id — one service, same shape as the collection.
      def show
        service = Service.find(params[:id])
        render json: service_document(service, service.repair_services.count)
      end

      # POST /api/v1/services — the owner registers a service from a script.
      def create
        attributes = service_params
        if attributes.to_h.empty?
          return render_errors(["The request has no service attributes to create"], :bad_request)
        end

        service = Service.new(attributes)
        if service.save
          render json: service_document(service, 0),
                 status: :created,
                 location: api_v1_service_url(service)
        else
          render_errors(service.errors.full_messages, :unprocessable_entity)
        end
      end

      private

      # The document a client reads, built key by key right here (not to_json,
      # as_json or a serializer gem) so each key is a decision written where it
      # is read. index, show and create all answer with this one shape.
      # A price travels as a string with two decimals (see docs/api.md).
      def service_document(service, times_charged)
        {
          id: service.id,
          name: service.name,
          price: money(service.price),
          times_charged: times_charged.to_i
        }
      end

      def money(amount)
        format("%.2f", amount)
      end

      # Strong parameters: nothing reaches the model without going through here,
      # and an attribute that is not on the list is dropped.
      def service_params
        params.expect(service: %i[name price active])
      end
    end
  end
end
