resource_name :s3cmd_package

property :s3_name, String, name_property: true

actions :install
default_action :install

action_class do
  include DOSpacesCustomResource::Helpers
end

action :install do
  rpm_path = node['do_space_resource']['rpm_path']

  case node['platform']
  when 'centos', 'redhat'
    package 'epel-release' do
      notifies :run, 'execute[yum makecache fast]', :immediately
    end

    execute 'yum makecache fast' do
      action :nothing
    end

    directory rpm_path

    node['do_space_resource']['centos_rpms'].each do |pkg_url|
      local_pkg = "#{rpm_path}/#{local_package(pkg_url)}"

      remote_file local_pkg do
        source pkg_url
      end

      package local_pkg do
        source local_pkg
      end
    end
  else
    apt_update
    package 's3cmd'
  end
end
