require 'spec_helper'

shared_examples 'a Yum class' do |value|
  value ||= 3

  it { is_expected.to contain_yum__config('installonly_limit').with_ensure(value.to_s) }
  it 'contains Exec[package-cleanup_oldkernels' do
    is_expected.to contain_exec('package-cleanup_oldkernels').with(
      command: "/usr/bin/package-cleanup --oldkernels --count=#{value} -y",
      refreshonly: true
    ).that_requires('Package[yum-utils]').that_subscribes_to('Yum::Config[installonly_limit]')
  end
end

describe 'yum' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end

      it { is_expected.to compile.with_all_deps }
      it { is_expected.to contain_class('yum') }

      context 'without any parameters' do
        let(:params) { {} }

        it_behaves_like 'a Yum class'
      end

      context 'when `config_options[installonly_limit]` is modified' do
        context 'with an Integer' do
          let(:params) { { config_options: { 'installonly_limit' => 10 } } }

          it_behaves_like 'a Yum class', 10
        end

        context 'with an invalid data type' do
          let(:params) { { config_options: { 'installonly_limit' => false } } }

          it 'raises a useful error' do
            is_expected.to raise_error(
              Puppet::PreformattedError,
              %r{The value or ensure for `\$yum::config_options\[installonly_limit\]` must be an Integer, but it is not\.}
            )
          end
        end
      end

      context 'when a config option other than `installonly_limit` is set' do
        context 'to a String' do
          let(:params) { { config_options: { 'cachedir' => '/var/cache/yum' } } }

          it { is_expected.to contain_yum__config('cachedir').with_ensure('/var/cache/yum') }
          it_behaves_like 'a Yum class'
        end

        context 'to an Integer' do
          let(:params) { { config_options: { 'debuglevel' => 5 } } }

          it { is_expected.to contain_yum__config('debuglevel').with_ensure('5') }
          it_behaves_like 'a Yum class'
        end

        context 'to a Boolean' do
          let(:params) { { config_options: { 'gpgcheck' => true } } }

          it { is_expected.to contain_yum__config('gpgcheck').with_ensure('1') }
          it_behaves_like 'a Yum class'
        end

        context 'using the nested attributes syntax' do
          context 'to a String' do
            let(:params) { { config_options: { 'my_cachedir' => { 'ensure' => '/var/cache/yum', 'key' => 'cachedir' } } } }

            it { is_expected.to contain_yum__config('my_cachedir').with_ensure('/var/cache/yum').with_key('cachedir') }
            it_behaves_like 'a Yum class'
          end

          context 'to an Integer' do
            let(:params) { { config_options: { 'my_debuglevel' => { 'ensure' => 5, 'key' => 'debuglevel' } } } }

            it { is_expected.to contain_yum__config('my_debuglevel').with_ensure('5').with_key('debuglevel') }
            it_behaves_like 'a Yum class'
          end

          context 'to a Boolean' do
            let(:params) { { config_options: { 'my_gpgcheck' => { 'ensure' => true, 'key' => 'gpgcheck' } } } }

            it { is_expected.to contain_yum__config('my_gpgcheck').with_ensure('1').with_key('gpgcheck') }
            it_behaves_like 'a Yum class'
          end
        end
      end

      context 'when clean_old_kernels => false' do
        let(:params) { { clean_old_kernels: false } }

        it { is_expected.to contain_exec('package-cleanup_oldkernels').without_subscribe }
      end
    end
  end

  context 'on an unsupported operating system' do
    let(:facts) { { os: { family: 'Solaris', name: 'Nexenta' } } }

    it { is_expected.to raise_error(Puppet::Error, %r{Nexenta not supported}) }
  end
end
