class UserDatatable < ApplicationDatatable
  extend Forwardable
  def_delegators :@view, :link_to, :raw, :button_tag, :users_delete_path

  def view_columns
    @view_columns ||= {
     id: { source: 'User.id', cond: :eq, searchable: true, orderable: true },
     name: { source: 'User.first_name', searchable: true, orderable: true},
     avatar: { source: 'User.id', searchable: false, orderable: false},
     roles: { source: 'User.id', searchable: false, orderable: false},
     actions: { source: 'User.id', searchable: false, orderable: false }
    }
  end

  private

  def data
    records.map do |record|
      avatar_url = (record.avatar.attached?) ? record.avatar.variant(resize: "100x100").processed.service_url : ''
      data_object = {toggle: 'modal', target: '#edit-modal',
        select: '',
        id: record.id,
        name: record.full_name,
        avatar_url: avatar_url,
        first_name: record.first_name,
        roles: (record.roles) ? record.roles.map {|r| r.name.capitalize }.join(', ') : '',
        last_name: record.last_name,
        username: record.username,
      }

      data_object_for_form = data_object.dup

      data_object_for_form[:roles] = raw(record.role_ids)
      data_object_for_form[:email] = record.email
      data_object[:avatar] = avatar_url

      actions = '<div class="btn-group" role="group" aria-label="Actions">'
      actions += button_tag(class: 'btn btn-primary', data: data_object_for_form, title: 'Edit this user') {|button| raw(' <i class="fa fa-pencil"></i>')} if options[:user].can?(:update, User, {id: record.id})
      confirm_message = "Are you sure you want to delete this user and all its associated records? This is not reversible and will most likely lead to broken links!"
      actions += button_tag(class: 'btn btn-danger delete-user', data: {id: record.id}, title: 'Delete this user') {|button| ' <i class="fa fa-trash-o"></i>'.html_safe} if options[:user].can?(:delete, User, {id: record.id})
      actions += '</div>'

      data_object[:avatar] = raw('<img class="datatable-image" src="' + avatar_url + '" />')
      data_object[:actions] = raw(actions)
      data_object['DT_RowId'] = "record_#{record.id}"
      data_object
    end
  end

  def get_raw_records
    User.all
  end

  # ==== Insert 'presenter'-like methods below if necessary
end
