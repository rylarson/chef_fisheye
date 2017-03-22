require 'serverspec'

set :backend, :exec

%w(git unzip).each do |pkg|
  describe package(pkg) do
    it { should be_installed }
  end
end

describe user('fisheye') do
  it { should exist }
  it { should belong_to_group 'fisheye' }
  it { should have_home_directory '/var/opt/fisheye' }
end

%w(/opt/fisheye /var/opt/fisheye /var/opt/fisheye/var /var/opt/fisheye/cache /var/opt/fisheye/lib /var/opt/fisheye/syntax).each do |directory|
  describe file(directory) do
    it { should exist }
    it { should be_directory }
    it { should be_owned_by('fisheye') }
    it { should be_grouped_into('fisheye') }
    it { should be_mode('755') }
  end
end

describe file('/tmp/kitchen/cache/fisheye.zip') do
  it { should exist }
  it { should be_file }
end

describe file('/opt/fisheye/fecru-4.3.1') do
  it { should_not exist }
end

# Sanity check a few of the fisheye installed files exist
%w(bin lib plugins config.xml).each do |file|
  describe file("/opt/fisheye/#{file}") do
    it { should exist }
    it { should be_owned_by('fisheye') }
  end
end

describe file('/var/opt/fisheye/config.xml') do |file|
  it { should exist }
  it { should be_owned_by('fisheye') }
  it { should be_grouped_into('fisheye') }
end

describe service('fisheye') do
  it { should be_enabled }
  it { should be_running }
end

[8059, 8060].each do |port|
  describe port(port) do
    it { should be_listening }
  end
end