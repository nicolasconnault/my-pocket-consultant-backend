class DashboardAbility
  include CanCan::Ability

  def initialize(user)
    if user.nil?
      return nil
    end

    if user.has_role? :admin
      can :manage, :all
      can :approve, Creative
    else
      if user.has_role? :advertising_manager
        can :manage, Creative
        can :approve, Creative
        can :manage, CreativeException
        can :manage, Advertiser
        can :manage, Campaign
        can :manage, CampaignFilter
        can :manage, CampaignStatistic
        can :manage, AdRollTemplate
        can :manage, AdRollTemplateSlot
      end

      if user.has_role? :sales_manager
        can :manage, BrandingProfile
        can :manage, Group
        can :manage, Store
        can :manage, Device
        can :manage, Setting
      end

      if user.has_role? :content_manager
        can :manage, Topic
        can :manage, TopicSection
        can :manage, TopicSectionVersion
        can :manage, TopicAlias
        can :manage, TopicCountry
        can :manage, TopicCategory
        can :manage, TopicReference
        can :manage, Category
        can :manage, CategoryRelationship
      end
      
      if user.has_role? :questionnaire_manager
        can :manage, Questionnaire
        can :manage, Question
        can :manage, QuestionOption
        can :manage, QuestionCondition
        can :manage, QuestionnaireVariable
        can :manage, QuestionnaireVariableRange
        can :manage, QuestionnaireCategory
        can :manage, QuestionnaireReportTemplate
      end

      if user.has_role?(:group_manager) && user.owner_type == 'Group'
        can [:read, :update, :create, :delete], Topic, owner_id: user.owner_id 
        can :toggle, Topic, owner_id: user.owner_id 
        can :attach_file, Topic, owner_id: user.owner_id 
        can :read, QuestionnaireResponse, questionnaire: {owner_id: user.owner_id} 
        can :read, QuestionnaireResponseAnswer, questionnaire_response: {questionnaire: {owner_id: user.owner_id} }
        can :manage, Solution, owner_id: user.owner_id
        can :read, Group, id: user.owner_id
        can [:read, :update], Setting, owner_type: 'Group', owner_id: user.owner_id
        # TODO Figure out how to grant access to children store and device settings 
        # can :read, Setting, owner_type: 'Store', owner_id: user.owner_id
        can :read, Store, group: { id: user.owner_id }
        can :read, Device, store: { group: { id: user.owner_id } }
        can :create, Device
        can :read, CmsStatistic, device: { store: { group: { id: user.owner_id } } }
      end

      if user.has_role?(:store_manager) && user.owner_type == 'Store'
        can [:read, :update, :create, :delete], Topic, owner_id: user.owner_id 
        can :toggle, Topic, owner_id: user.owner_id 
        can :attach_file, Topic, owner_id: user.owner_id 
        can :read, QuestionnaireResponse, questionnaire: {owner_id: user.owner_id} 
        can :read, QuestionnaireResponseAnswer, questionnaire_response: {questionnaire: {owner_id: user.owner_id} }
        can :manage, Solution, owner_id: user.owner_id
        can [:read, :update], Setting, owner_type: 'Store', owner_id: user.owner_id
        # TODO Figure out how to grant access to children device settings 
        # can :read, Setting, owner_type: 'Device', owner_id: user.owner_id
        can :read, Store, id: user.owner_id 
        can :read, Device, store: { id: user.owner_id }
        can :create, Device
        can :read, CmsStatistic, device: { store: {  id: user.owner_id } }
      end

      if user.has_role?(:device_manager) && user.owner_type == 'Device'
        can :read, Topic, owner_id: user.owner_id 
        can [:read, :update], Setting, owner_type: 'Device', owner_id: user.owner_id
        can :read, Device,  id: user.owner_id 
        can :read, CmsStatistic, device: {  id: user.owner_id }
      end

      if user.has_role?(:advertiser)
        can :manage, Campaign, owner_type: 'Advertiser', owner_id: user.owner_id
        can :manage, CampaignFilter, campaign: { owner_type: 'Advertiser', owner_id: user.owner_id }
        can :read, CampaignStatistic, campaign: { owner_type: 'Advertiser', owner_id: user.owner_id }
        can [:toggle, :read], Creative, owner_id: user.owner_id, owner_type: 'Advertiser'
        can :create, Creative
      end
    end
    
    # Define abilities for the passed in user here. For example:
    #
    #   user ||= User.new # guest user (not logged in)
    #   if user.admin?
    #     can :manage, :all
    #   else
    #     can :read, :all
    #   end
    #
    # The first argument to `can` is the action you are giving the user
    # permission to do.
    # If you pass :manage it will apply to every action. Other common actions
    # here are :read, :create, :update and :destroy.
    #
    # The second argument is the resource the user can perform the action on.
    # If you pass :all it will apply to every resource. Otherwise pass a Ruby
    # class of the resource.
    #
    # The third argument is an optional hash of conditions to further filter the
    # objects.
    # For example, here the user can only update published articles.
    #
    #   can :update, Article, :published => true
    #
    # See the wiki for details:
    # https://github.com/CanCanCommunity/cancancan/wiki/Defining-Abilities

  end
end
