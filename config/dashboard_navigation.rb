# -*- coding: utf-8 -*-
# Configures your navigation
SimpleNavigation::Configuration.run do |navigation|
  navigation.items do |primary|
    primary.item :reports, 'Reports', reports_stores_url, if: -> { can? :read, CmsStatistic } do |sub_nav| 
      sub_nav.item :reports_cms, '<i class="fa fa-bar-chart"></i> CMS Report'.html_safe, reports_stores_url, if: -> { can? :read, CmsStatistic }
    end

    primary.item :devices, 'Devices', devices_url, highlights_on: %r(/customers/devices), if: -> { can? :read, Device } do |sub_nav| 
      sub_nav.item :devices_list, '<i class="fa fa-desktop"></i> Manage'.html_safe, devices_url, if: -> { can? :read, Device }, highlights_on: %r(/customers/devices) 
    end

    primary.item :commercial_entities, 'Commercial Entities', groups_url, highlights_on: %r(/customers/), if: -> { can?(:manage, Group) || can?(:manage, Store) } do |sub_nav| 
      sub_nav.item :commercial_entities_branding_profiles, '<i class="fa fa-tags"></i> Branding Profiles'.html_safe, branding_profiles_url, highlights_on: %r(/customers/branding_profiles), if: -> { can? :manage, BrandingProfile }
      sub_nav.item :commercial_entities_groups, '<i class="fa fa-users"></i> Groups'.html_safe, groups_url, highlights_on: %r(/customers/groups), if: -> { can? :manage, Group }
      sub_nav.item :commercial_entities_stores, '<i class="fa fa-building"></i> Stores'.html_safe, stores_url, highlights_on: %r(/customers/stores), if: -> { can? :manage, Store }
      sub_nav.item :commercial_entities_stores_map, '<i class="fa fa-map"></i> Stores map'.html_safe, stores_map_url, highlights_on: %r(/customers/stores/map), if: -> { can? :manage, Store }
    end

    primary.item :cms, 'CMS', cms_topics_url, highlights_on: %r(/cms), if: -> { can?(:manage, Category) || can?(:manage, Topic) || can?(:manage, Questionnaire) } do |sub_nav| 
      sub_nav.item :cms_topics, '<i class="fa fa-book"></i> Topics'.html_safe, cms_topics_url, if: -> { can? :manage, Topic }, highlights_on: %r(/cms/topics)
      sub_nav.item :cms_categories, '<i class="fa fa-book"></i> Categories'.html_safe, cms_categories_url, if: -> { can? :manage, Category }, highlights_on: %r(/cms/categories)
      sub_nav.item :cms_assessments, '<i class="fgc fgc-homework"></i> Assessments'.html_safe, questionnaires_assessments_list_url, if: -> { can? :manage, Questionnaire }, highlights_on: -> {@questionnaire_type == 'assessment'}
      sub_nav.item :cms_training, '<i class="fgc fgc-homework"></i> Training'.html_safe, questionnaires_training_list_url, if: -> { can? :manage, Questionnaire }, highlights_on: -> {@questionnaire_type == 'training'}
    end

    primary.item :advertising, 'Advertising', campaigns_url, highlights_on: %r(/advertising), if: -> { can?(:read, Advertiser) || can?(:read, Creative) || can?(:read, CreativeException) || can?(:read, Campaign) || can?(:read, AdRollTemplate) } do |sub_nav| 
      sub_nav.item :advertising_advertisers, '<i class="fa fa-user"></i> Advertisers'.html_safe, advertisers_url, highlights_on: %r(/advertising/advertisers), if: -> { can? :read, Advertiser }
      sub_nav.item :advertising_creatives, '<i class="fa fa-play"></i> Creatives'.html_safe, creatives_url, highlights_on: %r(/advertising/creatives), if: -> { can? :read, Creative }
      sub_nav.item :advertising_creative_exceptions, '<i class="fa fa-exclamation-triangle"></i> Creative exceptions'.html_safe, creative_exceptions_url, highlights_on: %r(/advertising/creatives/exceptions), if: -> { can? :read, CreativeException }
      sub_nav.item :advertising_campaigns, '<i class="fa fa-calendar-plus-o"></i> Campaigns'.html_safe, campaigns_url, highlights_on: %r(/advertising/campaigns), if: -> { can? :read, Campaign }
      sub_nav.item :advertising_ad_roll_templates, '<i class="fa fa-refresh"></i> Ad Roll Templates'.html_safe, ad_roll_templates_url, highlights_on: %r(/advertising/ad_roll_templates), if: -> { can? :read, AdRollTemplate }
    end

    primary.item :administration, 'Administration', dashboard_users_url, highlights_on: %r(/admin), if: -> { can? :manage, User } do |sub_nav|
      sub_nav.item :administration_users, '<i class="fa fa-users"></i> Dashboard Users'.html_safe, dashboard_users_url, if: -> { can? :manage, User }, highlights_on: %r(/admin/users)
    end

  end

  navigation.name_generator = Proc.new do |name, item|

    if item.key == :'reports'
      "<i class='fa fa-bar-chart'></i> <span class='nav-label'>#{name}</span><span class='fa arrow'></span>".html_safe
    elsif item.key == :'cms'
      "<i class='fa fa-book'></i> <span class='nav-label'>#{name}</span><span class='fa arrow'></span>".html_safe
    elsif item.key == :'advertising'
      "<i class='fa fa-dollar'></i> <span class='nav-label'>#{name}</span><span class='fa arrow'></span>".html_safe
    elsif item.key == :'administration'
      "<i class='fa fa-gears'></i> <span class='nav-label'>#{name}</span><span class='fa arrow'></span>".html_safe
    elsif item.key == :'devices'
      "<i class='fa fa-desktop'></i> <span class='nav-label'>#{name}</span><span class='fa arrow'></span>".html_safe
    elsif item.key == :'commercial_entities'
      "<i class='fa fa-building'></i> <span class='nav-label'>#{name}</span><span class='fa arrow'></span>".html_safe
    else
      name
    end

  end
end
