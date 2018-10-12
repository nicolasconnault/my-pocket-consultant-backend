class NewsTypeDatatable < ApplicationDatatable
  extend Forwardable
  def_delegators :@view, :link_to, :raw, :button_tag, :users_delete_path

  def view_columns
    @view_columns ||= {
     id: { source: 'NewsType.id', cond: :eq, searchable: true, orderable: true },
     label: { source: 'NewsType.label', searchable: true, orderable: true},
     actions: { source: 'Company.id', searchable: false, orderable: false }
    }
  end

  private

  def data
    records.map do |record|
      data_object = {toggle: 'modal', target: '#edit-modal',
        select: '',
        id: record.id,
        label: record.label,
      }

      data_object_for_form = data_object.dup

      actions = '<div class="btn-group" role="group" aria-label="Actions">'
      actions += button_tag(class: 'btn btn-primary', data: data_object_for_form, title: 'Edit this news type') {|button| raw(' <i class="fa fa-pencil"></i>')} if options[:user].can?(:update, NewsType, {id: record.id})
      confirm_message = "Are you sure you want to delete this news type and all its associated records? This is not reversible!"
      actions += button_tag(class: 'btn btn-danger delete-news_type', data: {id: record.id}, title: 'Delete this news type') {|button| ' <i class="fa fa-trash-o"></i>'.html_safe} if options[:user].can?(:delete, NewsType, {id: record.id})
      actions += '</div>'

      data_object[:actions] = raw(actions)
      data_object['DT_RowId'] = "record_#{record.id}"
      data_object
    end
  end

  def get_raw_records
    NewsType.all
  end

  # ==== Insert 'presenter'-like methods below if necessary
end
