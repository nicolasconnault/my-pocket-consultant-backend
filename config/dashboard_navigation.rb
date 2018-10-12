# -*- coding: utf-8 -*-
# Configures your navigation
SimpleNavigation::Configuration.run do |navigation|
  navigation.items do |primary|

    primary.item :administration, 'Administration', users_url, highlights_on: %r(/admin), if: -> { can? :manage, User } do |sub_nav|
      sub_nav.item :administration_users,              '<i class="fa fa-users"></i> Users'.html_safe, users_url, if: -> { can? :manage, User }, highlights_on: %r(/admin/users)
      sub_nav.item :administration_companies,          '<i class="fa fa-building"></i> Companies'.html_safe, companies_url, if: -> { can? :manage, Company }, highlights_on: %r(/admin/companies)
      sub_nav.item :administration_company_categories, '<i class="fa fa-building"></i> Company Categories'.html_safe, company_categories_url, if: -> { can? :manage, CompanyCategory }, highlights_on: %r(/admin/company_categories)
      sub_nav.item :administration_tutorials,          '<i class="fa fa-mortar-board"></i> Tutorials'.html_safe, company_tutorials_url, if: -> { can? :manage, CompanyTutorial }, highlights_on: %r(/admin/company_tutorials)
      sub_nav.item :administration_tutorial_categories,'<i class="fa fa-mortar-board"></i> Tutorial Categories'.html_safe, tutorial_categories_url, if: -> { can? :manage, TutorialCategory }, highlights_on: %r(/admin/tutorial_categories)
      sub_nav.item :administration_news_types,         '<i class="fa fa-newspaper-o"></i> News Types'.html_safe, admin_news_types_url, if: -> { can? :manage, NewsType }, highlights_on: %r(/admin/admin_news_types)
    end

  end

  navigation.name_generator = Proc.new do |name, item|

    if item.key == :'administration'
      "<i class='fa fa-gears'></i> <span class='nav-label'>#{name}</span><span class='fa arrow'></span>".html_safe
    else
      name
    end

  end
end
