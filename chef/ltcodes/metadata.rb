name 'ltcodes'
maintainer 'KokybiskaSvetaine.lt'
maintainer_email 'info@kokybiskasvetaine.lt'
license 'MIT'
description 'Installs ltcodes, a command that checks Lithuanian personal codes, company codes, VAT numbers and IBANs'
version '0.1.0'
chef_version '>= 15.0'
source_url 'https://github.com/ello-lithuania/ltcodes'
issues_url 'https://github.com/ello-lithuania/ltcodes/issues'

%w(ubuntu debian redhat centos almalinux rocky amazon fedora mac_os_x windows).each do |os|
  supports os
end
