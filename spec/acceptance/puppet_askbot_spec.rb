require 'puppet-openstack_infra_spec_helper/spec_helper_acceptance'

describe 'puppet-askbot:: manifest', :if => ['debian', 'ubuntu'].include?(os[:family]) do
  def pp_path
    base_path = File.dirname(__FILE__)
    File.join(base_path, 'fixtures')
  end

  def preconditions_puppet_manifest
    module_path = File.join(pp_path, 'preconditions.pp')
    File.read(module_path)
  end

  before(:all) do
    apply_manifest(preconditions_puppet_manifest, catch_failures: true)
  end

  def init_puppet_manifest
    module_path = File.join(pp_path, 'askbot.pp')
    File.read(module_path)
  end

  it 'should work with no errors' do
    apply_manifest(init_puppet_manifest, catch_failures: true)
  end

  it 'should be idempotent' do
    apply_manifest(init_puppet_manifest, catch_changes: true)
  end

  describe command('curl -i -L -k http://localhost') do
    its(:stdout) { should contain('200 OK')
  end
end
