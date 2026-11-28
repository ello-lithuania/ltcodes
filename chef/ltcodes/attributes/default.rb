# Release of the ltcodes command to install, from
# https://github.com/ello-lithuania/ltcodes/releases
default['ltcodes']['version'] = '0.2.1'

# SHA-256 of each release archive, by build target.
default['ltcodes']['checksums'] = {
  'x86_64-unknown-linux-gnu' => '7772a784ec2be845240e36fe1b4849bfe0d3067dda51cab6927c55715c891be4',
  'aarch64-apple-darwin' => 'f8ff96cad43c47a0094e8152e519d196a24697c2658ec4e3f40bf5f9a219d888',
  'x86_64-pc-windows-msvc' => 'c68fb4e8f22dd266dad292fe46ccecd97843f6fe40dce14c55b75e6623bf6dfc',
}

default['ltcodes']['install_dir'] = platform?('windows') ? 'C:\ltcodes' : '/opt/ltcodes'
