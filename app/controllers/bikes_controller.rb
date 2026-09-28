class BikesController < ApplicationController
  before_action :set_bike, only: %i[show edit update destroy]

  def index
    @bikes = Bike.by_model.includes(:customer)
  end

  def show
    @repairs = @bike.repairs.newest_first.includes(bike: :customer)
  end

  # A bike can be born from the bikes page (no owner yet) or from a customer's
  # page (owner already chosen), so we seed customer_id from the query string.
  def new
    @bike = Bike.new(customer_id: params[:customer_id])
  end

  def create
    @bike = Bike.new(bike_params)
    if @bike.save
      redirect_to @bike, notice: "#{@bike.make_model} was added."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @bike.update(bike_params)
      redirect_to @bike, notice: "#{@bike.make_model} was updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @bike.destroy
      redirect_to bikes_path, notice: "#{@bike.make_model} was deleted.", status: :see_other
    else
      redirect_to @bike, alert: @bike.errors.full_messages.to_sentence, status: :see_other
    end
  end

  private

  def set_bike
    @bike = Bike.find(params[:id])
  end

  def bike_params
    params.expect(bike: [:make_model, :serial_number, :colour, :customer_id])
  end
end
