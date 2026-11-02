class RepairPolicy < ApplicationPolicy
  def index? = user.present?        # every role opens the index; the scope filters the rows
  def show?  = reads_record?
  def create? = user&.owner? || user&.counter?   # taking a bike in
  def new?    = create?

  def update?
    return false unless reads_record?
    return true if user&.owner?     # the owner edits any repair
    !record.handed_back?            # counter and mechanic cannot edit once handed back
  end
  def edit? = update?

  def destroy? = user&.owner?

  # The fields each role may write. The controller permits exactly this list, so a
  # field sent by hand that is not here is dropped. The account that took the repair
  # in is never a field — it is read from the session in the controller.
  def permitted_attributes
    if user&.owner? || user&.counter?
      [:bike_id, :mechanic_id, :status, :received_at, :promised_on, :handed_back_at, :diagnosis,
       { repair_services_attributes: %i[id service_id charged_price _destroy], intake_photos: [] }]
    else
      [:status, :diagnosis, { intake_photos: [] }]   # a mechanic: state, diagnosis, photos only
    end
  end

  # The form asks this to decide whether to show the bike, mechanic, dates and lines.
  def edit_full_details? = user&.owner? || user&.counter?

  class Scope < ApplicationPolicy::Scope
    def resolve
      if user&.owner? || user&.counter?
        scope.all
      elsif user&.mechanic? && user.staff_id.present?
        scope.where(mechanic_id: user.staff_id)
      else
        scope.none
      end
    end
  end

  private

  # A mechanic reads only the repairs assigned to the staff member joined to their
  # account; the owner and the counter read every repair.
  def reads_record?
    return true if user&.owner? || user&.counter?

    user&.mechanic? && user.staff_id.present? && record.mechanic_id == user.staff_id
  end
end
