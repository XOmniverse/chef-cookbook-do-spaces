resource_name :do_space

property :space, String, name_property: true
property :local_path, String, required: true
property :remote_path, String, default: ''
property :key, String, required: true
property :secret_key, String, required: true
property :region, String, required: true

actions :sync_local_dir, :sync_remote_dir
default_action :sync_local_dir

action_class do
  include DOSpacesCustomResource::Helpers
end

action :sync_local_dir do
  local_config = node['do_space_resource']['s3cfg_local_path']
  local_path = local_path_sanitize(new_resource.local_path)
  remote_path = remote_path_sanitize(new_resource.remote_path)
  sync_command = "s3cmd -c '#{local_config}' --delete-removed sync "\
                 "s3://#{new_resource.space}#{remote_path} #{local_path}"

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
  sync_command = "s3cmd -c '#{local_config}' --delete-removed sync "\
                 "#{local_path} s3://#{new_resource.space}#{remote_path}"

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
