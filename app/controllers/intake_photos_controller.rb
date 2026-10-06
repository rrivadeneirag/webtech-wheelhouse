class IntakePhotosController < ApplicationController
  # Removes a single intake photo. purge clears both Active Storage tables (the
  # attachment and, if unused, the blob) and the file on disk.
  def destroy
    repair = Repair.find(params[:repair_id])
    photo  = repair.intake_photos.find(params[:id])
    photo.purge
    redirect_back_or_to repair, notice: "Photo removed.", status: :see_other
  end
end
