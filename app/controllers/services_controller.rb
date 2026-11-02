class ServicesController < ApplicationController
  # The price list is public; creating, editing and deleting a service is not.
  allow_unauthenticated_access only: %i[index show]
  skip_after_action :verify_authorized, only: %i[index show]
  skip_after_action :verify_policy_scoped, only: :index

  before_action :set_service, only: %i[show edit update destroy]

  def index
    @services = Service.by_name
  end

  def show
    @lines = @service.repair_services.oldest_first.includes(repair: :bike)
  end

  def new
    @service = Service.new
    authorize @service
  end

  def create
    @service = Service.new(service_params)
    authorize @service
    if @service.save
      redirect_to @service, notice: "#{@service.name} was added."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @service
  end

  def update
    authorize @service
    if @service.update(service_params)
      redirect_to @service, notice: "#{@service.name} was updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @service
    if @service.destroy
      redirect_to services_path, notice: "#{@service.name} was deleted.", status: :see_other
    else
      redirect_to @service, alert: @service.errors.full_messages.to_sentence, status: :see_other
    end
  end

  private

  def set_service
    @service = Service.find(params[:id])
  end

  def service_params
    params.expect(service: [:name, :price, :active])
  end
end
