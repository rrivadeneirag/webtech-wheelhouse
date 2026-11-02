class ServicePolicy < ApplicationPolicy
  def index? = true   # the price list stays public
  def show?  = true
  def create? = user&.owner?
  def new?    = create?
  def update? = user&.owner?
  def edit?   = update?
  def destroy? = user&.owner?

  class Scope < ApplicationPolicy::Scope
    def resolve = scope.all
  end
end
