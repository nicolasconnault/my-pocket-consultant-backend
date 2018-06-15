module PageElementsHelper
  def page_heading title:, breadcrumbs:
    html = '
    <div class="row wrapper border-bottom white-bg page-heading">
        <div class="col-lg-10">
            <h2>' + title + '</h2>
            <ol class="breadcrumb">'

    breadcrumbs.each_with_index do |breadcrumb, i|
      html += '<li'

      if breadcrumb[1].nil?
        if breadcrumbs.size == (i + 1)
          html += ' class="active"><strong>' + breadcrumb[0] + '</strong></li>'
        else
          html += '>' + breadcrumb[0] + '</li>'
        end
      else
        html += '>' + link_to(breadcrumb[0], breadcrumb[1]) + '</li>'
      end
    end

    html += '</ol>
        </div>
        <div class="col-lg-2">

        </div>
    </div>'

    html.html_safe

  end

  def panel title:, contents:, width: 12, right_button: nil, progress_bar_unit: '%', progress_bar: false, progress_bar_current_value: 0, progress_bar_min_value: 0, progress_bar_max_value: 100, progress_bar_label: nil, progress_bar_percentage: 0
    html = '<div class="wrapper wrapper-content animated fadeInRight">
        <div class="row"> 
          <div class="col-lg-' + width.to_s + '">
            <div class="ibox float-e-margins">
              <div class="ibox-title">
                <h5>' + title + '</h5>'
    
    progress_bar_html = ''
    if progress_bar 
      progress_bar_class = 'primary'
      if progress_bar_current_value < progress_bar_max_value
        progress_bar_class = 'warning'
      elsif progress_bar_current_value > progress_bar_max_value
        progress_bar_class = 'danger'
      end

      progress_bar_html += ' 
        <div class="progress">
        ' + ((progress_bar_label.nil?) ? '' : '<p class="progress-label">' + progress_bar_label + '</p>') + '
        <div class="progress-bar progress-bar-' + progress_bar_class + '" role="progressbar" aria-valuenow="' + progress_bar_current_value.round.to_s + '" aria-valuemin="' + progress_bar_min_value.to_s + '" aria-valuemax="' + progress_bar_max_value.to_s + '" style="min-width: 2em; width: ' + progress_bar_percentage.to_s + '%;"> 
            ' + progress_bar_current_value.round.to_s + progress_bar_unit + ' ' + ((progress_bar_unit == '%') ? '' : '/ ' + progress_bar_max_value.to_s + progress_bar_unit) + '
          </div>
        </div>
      '
    end


    if right_button && progress_bar_class != 'danger'
      html += '<button class="btn btn-xs btn-primary pull-right"'
      right_button.each do |key, value|
        next if key == :title
        html += " #{key}=\"#{value}\""
      end
      html += ">#{right_button[:title]}</button>"
    end

    html += '
                <div class="ibox-content">
                  <div class="row">' + progress_bar_html + contents + '</div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>' 

    html.html_safe
  end
end
