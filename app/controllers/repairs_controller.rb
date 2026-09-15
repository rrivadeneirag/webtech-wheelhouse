class RepairsController < ApplicationController
  def index
    # Most recently received first — the counter cares about current work.
    @repairs = Repair.order(received_at: :desc)
  end

  def show
    @repair = Repair.find(params[:id])
  end
end
