class ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  # The base refuses everything. A policy that does not override a method
  # inherits a refusal, so an action whose rule was never written is never allowed.
  def index? = false
  def show? = false
  def create? = false
  def new? = create?
  def update? = false
  def edit? = update?
  def destroy? = false

  class Scope
    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      raise NoMethodError, "define #resolve in #{self.class}"
    end

    private

    attr_reader :user, :scope
  end
end
