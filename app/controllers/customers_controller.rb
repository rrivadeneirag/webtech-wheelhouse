class CustomersController < ApplicationController
  before_action :set_customer, only: %i[show edit update destroy]

  def index
    authorize Customer                       # a mechanic has no access: 403
    @customers = policy_scope(Customer).by_name.includes(:bikes)
  end

  def show
    authorize @customer
    @bikes = @customer.bikes.by_model.includes(:customer)
  end

  def new
    @customer = Customer.new
    authorize @customer
  end

  def create
    @customer = Customer.new(customer_params)
    authorize @customer
    if @customer.save
      redirect_to @customer, notice: "#{@customer.name} was added."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @customer
  end

  def update
    authorize @customer
    if @customer.update(customer_params)
      redirect_to @customer, notice: "#{@customer.name} was updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @customer
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
