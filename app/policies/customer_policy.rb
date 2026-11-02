class CustomerPolicy < ApplicationPolicy
  def index? = works_with_customers?
  def show?  = works_with_customers?
  def create? = works_with_customers?
  def new?    = create?
  def update? = works_with_customers?
  def edit?   = update?
  def destroy? = user&.owner?   # only the owner deletes

  class Scope < ApplicationPolicy::Scope
    def resolve
      (user&.owner? || user&.counter?) ? scope.all : scope.none
    end
  end

  private

  # The owner and the counter work with customers; a mechanic has no access.
  def works_with_customers? = user&.owner? || user&.counter?
end
