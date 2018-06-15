class Ability
  include CanCan::Ability

  def initialize(user)
    if user.nil?
      return nil
    end

    if user.has_role? :admin
      can :manage, :all
    else
      if user.has_role? :consultant
      end

      if user.has_role? :customer
      end
    end
  end
end
