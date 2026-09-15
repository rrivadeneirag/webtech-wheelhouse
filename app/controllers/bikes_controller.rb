class BikesController < ApplicationController
  def index
    @bikes = Bike.order(:make_model, :serial_number)
  end

  def show
    @bike = Bike.find(params[:id])
  end
end
