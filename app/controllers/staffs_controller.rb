class StaffsController < ApplicationController
  before_action :set_staff, only: %i[show edit update destroy]

  def index
    @staffs = Staff.by_name.includes(:repairs)
  end

  def show
    @repairs = @staff.repairs.newest_first.includes(bike: :customer)
                     .with_attached_intake_photos.with_rich_text_diagnosis
  end

  def new
    @staff = Staff.new
  end

  def create
    @staff = Staff.new(staff_params)
    if @staff.save
      redirect_to @staff, notice: "#{@staff.name} was added."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @staff.update(staff_params)
      redirect_to @staff, notice: "#{@staff.name} was updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @staff.destroy
      redirect_to staffs_path, notice: "#{@staff.name} was deleted.", status: :see_other
    else
      redirect_to @staff, alert: @staff.errors.full_messages.to_sentence, status: :see_other
    end
  end

  private

  def set_staff
    @staff = Staff.find(params[:id])
  end

  def staff_params
    params.expect(staff: [:name, :role])
  end
end
