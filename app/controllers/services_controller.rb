class ServicesController < ApplicationController
  def index
    @services = Service.by_name
  end

  def show
    @service = Service.find(params[:id])
    @lines = @service.repair_services.oldest_first.includes(repair: :bike)
  end
end
