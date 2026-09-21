class StaffsController < ApplicationController
  def index
    @staffs = Staff.by_name.includes(:repairs)
  end

  def show
    @staff = Staff.find(params[:id])
    @repairs = @staff.repairs.newest_first.includes(bike: :customer)
  end
end
