require File.expand_path('../helpers', __FILE__)

describe 'apache2::default' do
  include Helpers::Apache
  it 'installs apache' do
    package(node['apache']['package']).must_be_installed
  end
  it 'starts apache' do
    apache_service.must_be_running
  end
  it 'enables apache' do
    apache_service.must_be_enabled
  end
  it 'creates the conf.d directory' do
    directory("#{node['apache']['dir']}/conf.d").must_exist.with(:mode, "755")
  end
  it 'creates the logs directory' do
    directory(node['apache']['log_dir']).must_exist.with(:mode, "755")
  end
  it 'enables the default site' do
    file("#{node['apache']['dir']}/sites-enabled/000-default").must_exist
    file("#{node['apache']['dir']}/sites-available/default").must_exist
  end
  it 'ensures the debian-style apache module scripts are present' do
    %w{a2ensite a2dissite a2enmod a2dismod}.each do |mod_script|
      file("/usr/sbin/#{mod_script}").must_exist
    end
  end
  it 'reports server name only, not detailed version info' do
    assert_match(/^ServerTokens Prod *$/, File.read("#{node['apache']['dir']}/conf.d/security"))
  end
  it 'listens on port 80' do
    apache_configured_ports.must_include(80)
  end
  it 'only listens on port 443 when SSL is enabled' do
    unless ran_recipe?('apache2::mod_ssl')
      apache_configured_ports.wont_include(443)
    end
  end
  it 'reports server name only, not detailed version info' do
    file("#{node['apache']['dir']}/conf.d/security").must_match(/^ServerTokens Prod *$/)
  end
  it 'listens on port 80' do
    apache_configured_ports.must_include(80)
  end
  it 'only listens on port 443 when SSL is enabled' do
    unless ran_recipe?('apache2::mod_ssl')
      apache_configured_ports.wont_include(443)
    end
  end
  describe 'centos' do
    it 'ensures no modules are loaded in conf.d' do
      Dir["#{node['apache']['dir']}/conf.d/*"].each do |f|
        file(f).wont_include 'LoadModule'
      end
    end
  end
  describe 'configuration' do
    it { config.must_include '# Generated by Chef' }
    it { config.must_include %Q{ServerRoot "#{node['apache']['dir']}"} }
    it { config.must_include "Include #{node['apache']['dir']}/conf.d/" }
    it { apache_config_parses? }
  end
end
