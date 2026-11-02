class BikePolicy < ApplicationPolicy
  def index? = works_with_bikes?
  def show?  = works_with_bikes?
  def create? = works_with_bikes?
  def new?    = create?
  def update? = works_with_bikes?
  def edit?   = update?
  def destroy? = user&.owner?   # only the owner deletes

  class Scope < ApplicationPolicy::Scope
    def resolve
      (user&.owner? || user&.counter?) ? scope.all : scope.none
    end
  end

  private

  # The owner and the counter work with bikes; a mechanic has no access.
  def works_with_bikes? = user&.owner? || user&.counter?
end
