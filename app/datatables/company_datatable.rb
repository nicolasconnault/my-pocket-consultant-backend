class CompanyDatatable < ApplicationDatatable
  extend Forwardable
  def_delegators :@view, :link_to, :raw, :button_tag, :users_delete_path

  def view_columns
    @view_columns ||= {
     id: { source: 'Company.id', cond: :eq, searchable: true, orderable: true },
     label: { source: 'Company.label', searchable: true, orderable: true},
     category: { source: 'CompanyCategory.name', searchable: true, orderable: true},
     logo: { source: 'Company.id', searchable: false, orderable: false},
     actions: { source: 'Company.id', searchable: false, orderable: false }
    }
  end

  private

  def data
    records.map do |record|
      logo_url = (record.logo.attached?) ? record.logo.variant(resize: "100x100").processed.service_url : ''
      data_object = {toggle: 'modal', target: '#edit-modal',
        select: '',
        id: record.id,
        label: record.label,
        logo_url: logo_url,
        news_types: (record.news_types) ? record.news_types.map {|nt| nt.label }.join(', ') : '',
        category: record.company_category.name,
      }

      data_object_for_form = data_object.dup
      data_object_for_form[:news_types] = raw(record.news_type_ids)

      data_object[:logo] = logo_url

      actions = '<div class="btn-group" role="group" aria-label="Actions">'
      actions += button_tag(class: 'btn btn-primary', data: data_object_for_form, title: 'Edit this company') {|button| raw(' <i class="fa fa-pencil"></i>')} if options[:user].can?(:update, Company, {id: record.id})
      confirm_message = "Are you sure you want to delete this company and all its associated records? This is not reversible!"
      actions += button_tag(class: 'btn btn-danger delete-company', data: {id: record.id}, title: 'Delete this company') {|button| ' <i class="fa fa-trash-o"></i>'.html_safe} if options[:user].can?(:delete, Company, {id: record.id})
      actions += '</div>'

      data_object[:logo] = raw('<img class="datatable-image" src="' + logo_url + '" />')
      data_object[:actions] = raw(actions)
      data_object['DT_RowId'] = "record_#{record.id}"
      data_object
    end
  end

  def get_raw_records
    Company.joins(:company_category).select('companies.*, company_categories.name').distinct
  end

  # ==== Insert 'presenter'-like methods below if necessary
end
