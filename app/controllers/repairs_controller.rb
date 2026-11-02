class RepairsController < ApplicationController
  before_action :set_repair, only: %i[show edit update destroy]

  BLANK_LINES = 3 # empty service lines a form offers so you can add work without JS

  # Owner and counter see every repair; a mechanic sees only their own. The scope
  # is the same relation the show page is protected by, so the index and the pages
  # agree. A fixed number of queries for each role.
  def index
    @repairs = policy_scope(Repair)
                 .newest_first
                 .includes(:taken_in_by, bike: :customer)
                 .with_attached_intake_photos
                 .with_rich_text_diagnosis
  end

  def show
    authorize @repair
    @lines = @repair.repair_services.oldest_first.includes(:service)
  end

  def new
    @repair = Repair.new(bike_id: params[:bike_id], received_at: Time.current)
    authorize @repair
    pad_lines(@repair)
  end

  def create
    @repair = Repair.new
    @repair.taken_in_by = Current.user   # from the session, never the form
    authorize @repair
    assign_and_attach(@repair)
    if @repair.save
      redirect_to @repair, notice: "Repair ##{@repair.id} was created."
    else
      pad_lines(@repair)
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @repair
    pad_lines(@repair)
  end

  def update
    authorize @repair
    assign_and_attach(@repair)
    if @repair.save
      redirect_to @repair, notice: "Repair ##{@repair.id} was updated."
    else
      pad_lines(@repair)
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @repair
    if @repair.destroy
      redirect_to repairs_path, notice: "Repair ##{@repair.id} was deleted.", status: :see_other
    else
      redirect_to @repair, alert: @repair.errors.full_messages.to_sentence, status: :see_other
    end
  end

  private

  def set_repair
    @repair = Repair.with_attached_intake_photos
                    .with_rich_text_diagnosis
                    .includes(:taken_in_by, :mechanic, bike: :customer)
                    .find(params[:id])
  end

  # Assigns only the fields the policy permits for this account, then adds any new
  # photos to the ones the repair has (forcing the record dirty so the model's
  # validations gate the attach). A field outside the permitted list is dropped.
  def assign_and_attach(repair)
    attrs = permitted_attributes(repair)
    files = Array(attrs[:intake_photos]).reject(&:blank?)
    repair.assign_attributes(attrs.except(:intake_photos))
    return if files.empty?

    repair.updated_at = Time.current unless repair.changed?
    repair.intake_photos.attach(files)
  end

  def pad_lines(repair)
    missing = BLANK_LINES - repair.repair_services.count(&:new_record?)
    missing.times { repair.repair_services.build } if missing.positive?
  end
end
