module Api
  module V1
    # The one base controller of the API. It is built on ActionController::API,
    # so it carries no CSRF token, no session and no HTML layout — a program,
    # not a browser, is on the other end. Errors are turned into one JSON shape
    # here, once, instead of in each action.
    class BaseController < ActionController::API
      rescue_from ActiveRecord::RecordNotFound, with: :render_not_found
      rescue_from ActionController::ParameterMissing, with: :render_parameter_missing

      private

      # Every error of the API is a JSON object with one key, "errors", whose
      # value is a list of strings. A client handles every error in one place.
      def render_errors(messages, status)
        render json: { errors: Array(messages) }, status: status
      end

      def render_not_found(_exception)
        render_errors(["No record was found with that id"], :not_found)
      end

      def render_parameter_missing(_exception)
        render_errors(["The request body is missing the parameters this route needs"], :bad_request)
      end

      # Checks the Bearer token in the Authorization header before the action
      # runs. It reads the header only — never the query string or the body —
      # and compares in constant time, so the check does not leak how much of
      # the token matched. A missing or wrong token ends as 401 with the shape.
      def authenticate_token!
        provided = ActionController::HttpAuthentication::Token.token_and_options(request)&.first.to_s
        expected = Rails.application.credentials.api_token.to_s

        return if expected.present? &&
                  provided.present? &&
                  ActiveSupport::SecurityUtils.secure_compare(provided, expected)

        render_errors(["A valid API token is required for this route"], :unauthorized)
      end
    end
  end
end
