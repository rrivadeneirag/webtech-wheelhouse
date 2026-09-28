class CustomersController < ApplicationController
  before_action :set_customer, only: %i[show edit update destroy]

  def index
    @customers = Customer.by_name.includes(:bikes)
  end

  def show
    @bikes = @customer.bikes.by_model.includes(:customer)
  end

  def new
    @customer = Customer.new
  end

  def create
    @customer = Customer.new(customer_params)
    if @customer.save
      redirect_to @customer, notice: "#{@customer.name} was added."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @customer.update(customer_params)
      redirect_to @customer, notice: "#{@customer.name} was updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @customer.destroy
      redirect_to customers_path, notice: "#{@customer.name} was deleted.", status: :see_other
    else
      redirect_to @customer, alert: @customer.errors.full_messages.to_sentence, status: :see_other
    end
  end

  private

  def set_customer
    @customer = Customer.find(params[:id])
  end

  def customer_params
    params.expect(customer: [:name, :phone])
  end
end
