class RepairsController < ApplicationController
  before_action :set_repair, only: %i[show edit update destroy]

  BLANK_LINES = 3 # empty service lines a form offers so you can add work without JS

  def index
    @repairs = Repair.newest_first.includes(bike: :customer)
  end

  def show
    @lines = @repair.repair_services.oldest_first.includes(:service)
  end

  def new
    @repair = Repair.new(bike_id: params[:bike_id], received_at: Time.current)
    pad_lines(@repair)
  end

  def create
    @repair = Repair.new(repair_params)
    if @repair.save
      redirect_to @repair, notice: "Repair ##{@repair.id} was created."
    else
      pad_lines(@repair)
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    pad_lines(@repair)
  end

  def update
    if @repair.update(repair_params)
      redirect_to @repair, notice: "Repair ##{@repair.id} was updated."
    else
      pad_lines(@repair)
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @repair.destroy
      redirect_to repairs_path, notice: "Repair ##{@repair.id} was deleted.", status: :see_other
    else
      redirect_to @repair, alert: @repair.errors.full_messages.to_sentence, status: :see_other
    end
  end

  private

  def set_repair
    @repair = Repair.includes(:mechanic, bike: :customer).find(params[:id])
  end

  # Top up the form with empty lines so there is always room to add services,
  # without any JavaScript. Lines left blank are ignored on save (reject_if).
  def pad_lines(repair)
    missing = BLANK_LINES - repair.repair_services.count(&:new_record?)
    missing.times { repair.repair_services.build } if missing.positive?
  end

  def repair_params
    params.expect(
      repair: [
        :bike_id, :mechanic_id, :status, :received_at, :promised_on, :handed_back_at,
        repair_services_attributes: [[:id, :service_id, :charged_price, :_destroy]]
      ]
    )
  end
end
