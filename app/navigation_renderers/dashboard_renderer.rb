class DashboardRenderer < SimpleNavigation::Renderer::Base
  def render(item_container)
    if skip_if_empty? && item_container.empty?
      ''
    else
      tag = options[:ordered] ? :ol : :ul
      content = list_content(item_container)

      if item_container.level == 1
        content.html_safe
      else
        nav_class = (item_container.level == 2) ? 'second' : 'third'
        html_attributes = {class: 'nav nav-' + nav_class + '-level collapse'}
        content_tag(tag, content, item_container.dom_attributes.merge(html_attributes))
      end
    end
  end

  private

  def list_content(item_container)
    item_container.items.map { |item|
      li_options = item.html_options.except(:link)
      li_content = tag_for(item)
      if include_sub_navigation?(item)
        li_content << render_sub_navigation_for(item)
      end
      content_tag(:li, li_content, li_options)
    }.join
  end

  def suppress_link?(item)
    item.sub_navigation && item.sub_navigation.level == 2
  end

  def tag_for(item)
    if suppress_link?(item)
      '<a href="">' + content_tag('span', item.name, link_options_for(item).except(:method)) + '</a>'
    else
      link_to(item.name, item.url, options_for(item))
    end
  end
  
  
end
