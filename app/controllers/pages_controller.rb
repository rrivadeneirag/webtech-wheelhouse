class PagesController < ApplicationController
  def home
  end

  def services
    # Read the wall list from the database, ordered by name (a deliberate order).
    @services = Service.order(:name)
  end

  def visiting
  end

  def about
  end
end
