class ApplicationController < ActionController::Base
  include Authentication
  include Pundit::Authorization

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  # Every action must either authorize a record or scope its index. A controller
  # (or action) that forgets raises in development, so nothing is left unchecked.
  after_action :verify_authorized, except: :index
  after_action :verify_policy_scoped, only: :index

  # A request the policy refuses ends on a 403 page inside the layout, never a
  # Rails error page. A visitor with no session is sent to sign in before this,
  # by the authentication filter, so a visitor never sees the 403 page.
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  private

  # Policies receive the account of the current session, and nothing else.
  def pundit_user
    Current.user
  end

  def user_not_authorized
    respond_to do |format|
      format.html { render "pages/forbidden", status: :forbidden }
      format.any  { head :forbidden }
    end
  end
end
