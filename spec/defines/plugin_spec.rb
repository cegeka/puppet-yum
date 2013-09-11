#!/usr/bin/env rspec

require 'spec_helper'

describe "yum::plugin" do
  context "with title 'versionlock'" do
    let (:title) { 'versionlock' }

    context "on osfamily Debian" do
      let (:facts) { { :osfamily => 'Debian' } }

      it { expect { subject }.to raise_error(
        Puppet::Error, /only supported on osfamily RedHat/
      )}
    end

    context "on osfamily RedHat" do
      let (:default_facts) { { :osfamily => 'RedHat' } }

      shared_examples "osfamily RedHat" do
        context "with ensure => 'installed'" do
          let (:params) { { :ensure => 'installed' } }

          it { expect { subject }.to raise_error(
            Puppet::Error, /parameter ensure must be present, absent or purged/
          )}
        end

        context "with enable => 'present'" do
          let (:params) { { :enable => 'present' } }

          it { expect { subject }.to raise_error(
            Puppet::Error, /parameter enable must be true or false/
          )}
        end

        context "without parameters" do
          let (:params) { {} }

          it do
            should contain_yum__plugin('versionlock').with({
              :ensure => 'present',
              :enable => true
            })
          end
        end
      end

      context "on RHEL5" do
        let (:facts) { default_facts.merge( {
          :operatingsystemrelease => '5'
        } )}

        it_behaves_like "osfamily RedHat"

        context "with ensure => absent" do
          let (:params) { { :ensure => 'absent' } }

          it do
            should contain_package('yum-versionlock').with({
              :ensure => 'absent'
            })
          end

          it do
            should_not contain_augeas('yum-plugin-versionlock-enable')
          end
        end

        context "with ensure => present and enable => false" do
          let (:params) { { :ensure => 'present', :enable => false } }

          it do
            should contain_package('yum-versionlock').with({
              :ensure => 'present'
            })
          end

          it do
            should contain_augeas('yum-plugin-versionlock-enable').with({
              :incl    => '/etc/yum/pluginconf.d/versionlock.conf',
              :lens    => 'Yum.lns',
              :context => '/files/etc/yum/pluginconf.d/versionlock.conf/main',
              :changes => 'set enabled 0',
              :onlyif  => 'match size enabled[. = \'0\'] == 0',
            })
          end
        end

        context "with ensure => present and enable => true" do
          let (:params) { { :ensure => 'present', :enable => true } }

          it do
            should contain_package('yum-versionlock').with({
              :ensure => 'present'
            })
          end

          it do
            should contain_augeas('yum-plugin-versionlock-enable').with({
              :incl    => '/etc/yum/pluginconf.d/versionlock.conf',
              :lens    => 'Yum.lns',
              :context => '/files/etc/yum/pluginconf.d/versionlock.conf/main',
              :changes => 'set enabled 1',
              :onlyif  => 'match size enabled[. = \'1\'] == 0',
            })
          end
        end
      end

      context "on RHEL6" do
        let (:facts) { default_facts.merge( {
          :operatingsystemrelease => '6'
        } )}

        it_behaves_like "osfamily RedHat"

        context "with ensure => absent" do
          let (:params) { { :ensure => 'absent' } }

          it do
            should contain_package('yum-plugin-versionlock').with({
              :ensure => 'absent'
            })
          end

          it do
            should_not contain_augeas('yum-plugin-versionlock-enable')
          end
        end

        context "with ensure => present and enable => false" do
          let (:params) { { :ensure => 'present', :enable => false } }

          it do
            should contain_package('yum-plugin-versionlock').with({
              :ensure => 'present'
            })
          end

          it do
            should contain_augeas('yum-plugin-versionlock-enable').with({
              :incl    => '/etc/yum/pluginconf.d/versionlock.conf',
              :lens    => 'Yum.lns',
              :context => '/files/etc/yum/pluginconf.d/versionlock.conf/main',
              :changes => 'set enabled 0',
              :onlyif  => 'match size enabled[. = \'0\'] == 0',
            })
          end
        end

        context "with ensure => present and enable => true" do
          let (:params) { { :ensure => 'present', :enable => true } }

          it do
            should contain_package('yum-plugin-versionlock').with({
              :ensure => 'present'
            })
          end

          it do
            should contain_augeas('yum-plugin-versionlock-enable').with({
              :incl    => '/etc/yum/pluginconf.d/versionlock.conf',
              :lens    => 'Yum.lns',
              :context => '/files/etc/yum/pluginconf.d/versionlock.conf/main',
              :changes => 'set enabled 1',
              :onlyif  => 'match size enabled[. = \'1\'] == 0',
            })
          end
        end
      end
    end
  end

  context "with title 'rhn-plugin'" do
    let (:title) { 'rhn-plugin' }

    context "on osfamily RedHat" do
      let (:facts) { { :osfamily => 'RedHat' } }

      context "with ensure => absent" do
        let (:params) { { :ensure => 'absent' } }

        it do
          should contain_package('yum-rhn-plugin').with({
            :ensure => 'absent'
          })
        end
      end

      context "with ensure => present" do
        let (:params) { { :ensure => 'present' } }

        it do
          should contain_package('yum-rhn-plugin').with({
            :ensure => 'present'
          })
        end
      end
    end
  end
end
