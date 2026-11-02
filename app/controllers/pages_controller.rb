class PagesController < ApplicationController
  # These actions run the authentication flow or show static pages; they do not
  # authorize a resource (see docs/decisions.md).
  skip_after_action :verify_authorized
  skip_after_action :verify_policy_scoped

  def home
  end

  def visiting
  end

  def about
  end
end
