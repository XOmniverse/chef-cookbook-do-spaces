resource_name :do_space

property :space, String, name_property: true
property :local_path, String, default: '/do_space'
property :remote_path, String, default: ''
property :key, String, required: true
property :secret_key, String, required: true
property :region, String, default: 'nyc3'
property :delete_removed, [true, false], default: false
property :public_space, [true, false, nil], default: nil

actions :sync_local_dir, :sync_remote_dir, :create, :delete, :update, :empty
default_action :create

action_class do
  include DOSpacesCustomResource::Helpers
end

action :create do
  local_config = node['do_space_resource']['s3cfg_local_path']
  create_command = "s3cmd -c '#{local_config}' mb s3://#{new_resource.space}"
  perm_command = "s3cmd -c '#{local_config}' setacl s3://#{new_resource.space}"

  perm_command += if new_resource.public_space
                    ' --acl-public'
                  else
                    ' --acl-private'
                  end

  s3cmd_package 'install s3cmd'

  template local_config do
    cookbook 'do-spaces'
    source 's3cfg.erb'
    variables(
      key: new_resource.key,
      secret_key: new_resource.secret_key,
      region: new_resource.region
    )
  end

  execute create_command do
    returns [0, 13]
  end

  execute perm_command unless new_resource.public_space.nil?
end

action :delete do
  local_config = node['do_space_resource']['s3cfg_local_path']
  delete_command = "s3cmd -c '#{local_config}' rb s3://#{new_resource.space}"

  s3cmd_package 'install s3cmd'

  template local_config do
    cookbook 'do-spaces'
    source 's3cfg.erb'
    variables(
      key: new_resource.key,
      secret_key: new_resource.secret_key,
      region: new_resource.region
    )
  end

  execute delete_command do
    returns [0, 12]
  end
end

action :empty do
  local_config = node['do_space_resource']['s3cfg_local_path']
  empty_command = "s3cmd -c '#{local_config}' rm s3://#{new_resource.space}/"\
                  ' --recursive --force'

  s3cmd_package 'install s3cmd'

  template local_config do
    cookbook 'do-spaces'
    source 's3cfg.erb'
    variables(
      key: new_resource.key,
      secret_key: new_resource.secret_key,
      region: new_resource.region
    )
  end

  execute empty_command
end

action :update do
  local_config = node['do_space_resource']['s3cfg_local_path']
  perm_command = "s3cmd -c '#{local_config}' setacl s3://#{new_resource.space}"

  perm_command += if new_resource.public_space
                    ' --acl-public'
                  else
                    ' --acl-private'
                  end

  s3cmd_package 'install s3cmd'

  template local_config do
    cookbook 'do-spaces'
    source 's3cfg.erb'
    variables(
      key: new_resource.key,
      secret_key: new_resource.secret_key,
      region: new_resource.region
    )
  end

  execute perm_command unless new_resource.public_space.nil?
end

action :sync_local_dir do
  local_config = node['do_space_resource']['s3cfg_local_path']
  local_path = local_path_sanitize(new_resource.local_path)
  remote_path = remote_path_sanitize(new_resource.remote_path)

  sync_command = "s3cmd -c '#{local_config}' "
  sync_command += '--delete-removed ' if new_resource.delete_removed
  sync_command += "sync s3://#{new_resource.space}#{remote_path} #{local_path}"

  s3cmd_package 'install s3cmd'

  template local_config do
    cookbook 'do-spaces'
    source 's3cfg.erb'
    variables(
      key: new_resource.key,
      secret_key: new_resource.secret_key,
      region: new_resource.region
    )
  end

  directory local_path

  execute sync_command
end

action :sync_remote_dir do
  local_config = node['do_space_resource']['s3cfg_local_path']
  local_path = local_path_sanitize(new_resource.local_path)
  remote_path = remote_path_sanitize(new_resource.remote_path)

  sync_command = "s3cmd -c '#{local_config}' "
  sync_command += '--delete-removed ' if new_resource.delete_removed
  sync_command += "sync #{local_path} s3://#{new_resource.space}#{remote_path}"

  s3cmd_package 'install s3cmd'

  template local_config do
    cookbook 'do-spaces'
    source 's3cfg.erb'
    variables(
      key: new_resource.key,
      secret_key: new_resource.secret_key,
      region: new_resource.region
    )
  end

  directory local_path

  execute sync_command
end
