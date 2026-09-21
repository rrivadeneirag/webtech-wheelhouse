class RepairsController < ApplicationController
  def index
    @repairs = Repair.newest_first.includes(bike: :customer)
  end

  def show
    @repair = Repair.includes(:mechanic, bike: :customer).find(params[:id])
    @lines = @repair.repair_services.oldest_first.includes(:service)
  end
end
