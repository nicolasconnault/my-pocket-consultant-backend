class AppAbility
  include CanCan::Ability

  def initialize(user)
    if user.nil?
      return nil
    end

    if user.has_role? :admin
      can :manage, :all
    end
    if user.has_role? :consultant
      can :manage, Subscription
    end
  end
end
