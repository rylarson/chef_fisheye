FISHEYE_INSTANCE_DIR = '/var/opt/fisheye'
FISHEYE_INSTALL_DIR = '/opt/fisheye'

user 'fisheye' do
  comment 'Atlassian FishEye'
  home FISHEYE_INSTANCE_DIR
  system true
  manage_home true
end

FISHEYE_ZIP_FILE_PATH = "#{Chef::Config[:file_cache_path]}/fisheye.zip"

remote_file FISHEYE_ZIP_FILE_PATH do
  source node['fisheye']['zip_file_uri']
end

# Create the recommended file layout for production environment
directory FISHEYE_INSTANCE_DIR do
  owner 'fisheye'
  group 'fisheye'
  mode 0755
end

directory FISHEYE_INSTALL_DIR do
  owner 'fisheye'
  group 'fisheye'
  mode 0755
end

%w(var cache lib syntax).each do |dir|
  directory File.join(FISHEYE_INSTANCE_DIR, dir) do
    owner 'fisheye'
    group 'fisheye'
    mode 0755
  end
end

package 'unzip'

bash 'Unzip FishEye into install directory' do
  cwd FISHEYE_INSTALL_DIR
  code <<-EOH
    unzip #{FISHEYE_ZIP_FILE_PATH}
    mv fecru-*/* .
    rm -rf fecru-*
  EOH
  user 'fisheye'

  # Only install if this directory is empty, this cookbook doesn't handle upgrades
  only_if { ::Dir[File.join(FISHEYE_INSTALL_DIR, '*')].empty? }
end

file '/etc/profile.d/fisheye.sh' do
  owner 'root'
  group 'root'
  mode 0755
  content "export FISHEYE_INST=#{FISHEYE_INSTANCE_DIR}"
end

execute 'systemctl-daemon-reload' do
  command '/bin/systemctl --system daemon-reload'
  action :nothing
end

template '/etc/systemd/system/fisheye.service' do
  source 'fisheye.service.erb'
  owner 'root'
  group 'root'
  mode 0755
  variables(
      :fisheye_install_dir => FISHEYE_INSTALL_DIR,
      :user => 'fisheye',
      :group => 'fisheye'
  )
  notifies :run, 'execute[systemctl-daemon-reload]', :immediately
end

template "#{FISHEYE_INSTANCE_DIR}/config.xml" do
  source 'config.xml.erb'
  owner 'fisheye'
  group 'fisheye'
  mode 0644
end

service 'fisheye' do
  action [:enable, :start]
end

# FishEye uses git to checkout/index repos
package 'git'
