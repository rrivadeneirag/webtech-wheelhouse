class BikesController < ApplicationController
  def index
    @bikes = Bike.by_model.includes(:customer)
  end

  def show
    @bike = Bike.find(params[:id])
    @repairs = @bike.repairs.newest_first.includes(bike: :customer)
  end
end
