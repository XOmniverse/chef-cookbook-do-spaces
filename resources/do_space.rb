resource_name :do_space

property :space, String, name_property: true
property :local_path, String, required: true
property :remote_path, String, default: ''
property :key, String, required: true
property :secret_key, String, required: true
property :region, String, required: true
property :s3cfg_template, String, default: ''

actions :sync_local_dir, :sync_remote_dir
default_action :sync_local_dir

action :sync_local_dir do
  package 's3cmd'

  template '/tmp/dospace_s3cfg' do
    if new_resource.s3cfg_template == ''
      cookbook 'do-spaces'
      source 's3cfg.erb'
    else
      source new_resource.s3cfg_template
    end

    variables(
      key: new_resource.key,
      secret_key: new_resource.secret_key,
      region: new_resource.region
    )
  end

  local_path = new_resource.local_path
  local_path += '/' unless local_path[-1] == '/'

  remote_path = new_resource.remote_path
  remote_path += '/' unless remote_path[-1] == '/' || remote_path == ''
  unless remote_path[0] == '/' || remote_path == ''
    remote_path = '/' + remote_path
  end

  directory local_path

  execute 'clone_space' do
    command 's3cmd -c "/tmp/dospace_s3cfg" --delete-removed sync '\
            "s3://#{new_resource.space}#{remote_path} #{local_path}"
  end
end

action :sync_remote_dir do
  package 's3cmd'

  template '/tmp/dospace_s3cfg' do
    cookbook 'do-spaces'
    source 's3cfg.erb'
    variables(
      key: new_resource.key,
      secret_key: new_resource.secret_key,
      region: new_resource.region
    )
  end

  local_path = new_resource.local_path
  local_path += '/' unless local_path[-1] == '/'

  remote_path = new_resource.remote_path
  remote_path += '/' unless remote_path[-1] == '/' || remote_path == ''
  unless remote_path[0] == '/' || remote_path == ''
    remote_path = '/' + remote_path
  end

  directory local_path

  execute 'clone_space' do
    command 's3cmd -c "/tmp/dospace_s3cfg" --delete-removed sync '\
            "#{local_path} s3://#{new_resource.space}#{remote_path}"
  end
end
