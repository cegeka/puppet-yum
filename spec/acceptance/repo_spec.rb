require 'spec_helper_acceptance'

describe 'yum::repo' do

  describe 'running puppet code' do
    it 'should work with no errors' do
      pp = <<-EOS
        include ::yum
        yum::repo { 'dummy':
          scheme        => 'https',
          host          => 'yum.dummy.tld',
          sslverify     => 'True',
          sslcacert     => '/etc/path/to/ca-bundle.crt',
          sslclientcert => "/etc/path/to/clientcert.crt",
          sslclientkey  => "/etc/path/to/clientcert.key",
          gpgcheck      => 1,
          gpgkey        => "file:///etc/pki/rpm-gpg/RPM-GPG-KEY-dummy-release"
        }
      EOS

      # Run it twice and test for idempotency
      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end

    describe file '/etc/yum.repos.d/dummy.repo' do
      it { is_expected.to be_file }
      its(:content) { should contain /yum.dummy.tld/ }
    end

  end
end

