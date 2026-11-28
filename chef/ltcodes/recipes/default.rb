#
# Cookbook:: ltcodes
# Recipe:: default
#
# Installs the ltcodes command from the GitHub release archives.

version = node['ltcodes']['version']
machine = node['kernel']['machine']

target =
  if platform?('windows')
    'x86_64-pc-windows-msvc'
  elsif platform?('mac_os_x') && %w(arm64 aarch64).include?(machine)
    'aarch64-apple-darwin'
  elsif platform_family?('debian', 'rhel', 'amazon', 'fedora', 'suse') && machine == 'x86_64'
    'x86_64-unknown-linux-gnu'
  else
    raise "ltcodes: no prebuilt binary for #{node['platform']} on #{machine}"
  end

ext = platform?('windows') ? 'zip' : 'tar.gz'
archive = ::File.join(Chef::Config[:file_cache_path], "ltcodes-#{version}-#{target}.#{ext}")
install_dir = node['ltcodes']['install_dir']

remote_file archive do
  source "https://github.com/ello-lithuania/ltcodes/releases/download/rust-v#{version}/ltcodes-#{target}.#{ext}"
  checksum node['ltcodes']['checksums'][target]
end

archive_file archive do
  destination install_dir
  extract_options [:time, :permissions]
  overwrite :auto
end

if platform?('windows')
  windows_path install_dir
else
  link '/usr/local/bin/ltcodes' do
    to ::File.join(install_dir, 'ltcodes')
  end
end
