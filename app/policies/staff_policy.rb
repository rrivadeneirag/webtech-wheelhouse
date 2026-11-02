class StaffPolicy < ApplicationPolicy
  def index? = user.present?   # owner, counter and mechanic all read staff
  def show?  = user.present?
  def create? = user&.owner?
  def new?    = create?
  def update? = user&.owner?
  def edit?   = update?
  def destroy? = user&.owner?

  class Scope < ApplicationPolicy::Scope
    def resolve = scope.all
  end
end
