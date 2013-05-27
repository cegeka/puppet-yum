#!/usr/bin/env rspec

require 'spec_helper'

describe "yum::setting" do
  context "with title 'plugins'" do
    let (:title) { 'plugins' }

    context "on osfamily Debian" do
      let (:facts) { { :osfamily => 'Debian' } }

      it { expect { subject }.to raise_error(
        Puppet::Error, /only supported on osfamily RedHat/
      )}
    end
  end

  context "with title 'plugins'" do
    let (:title) { 'plugins' }

    context "on osfamily RedHat" do
      let (:facts) { { :osfamily => 'RedHat' } }

      context "without required parameters" do
        let (:params) { {} }

        it { expect { subject }.to raise_error(
          Puppet::Error, /required parameter value must be a non-empty string or integer/
        )}
      end

      context "with ensure => 'installed'" do
        let (:params) { { :ensure => 'installed' } }

        it { expect { subject }.to raise_error(
          Puppet::Error, /parameter ensure must be present or absent/
        )}
      end

      context "with ensure => 'absent'" do
        let (:params) { { :ensure => 'absent' } }

        it do
          should contain_augeas('yum::setting::plugins').with({
            :incl    => '/etc/yum.conf',
            :lens    => 'Yum.lns',
            :context => '/files/etc/yum.conf/main',
            :changes => 'rm plugins',
            :onlyif  => 'match plugins size > 0',
          })
        end
      end

      context "with value => false" do
        let (:params) { { :value => false } }

        it { expect { subject }.to raise_error(
          Puppet::Error, /required parameter value must be a non-empty string or integer/
        )}
      end

      context "with value => '1'" do
        let (:params) { { :value => '1' } }

        it do
          should contain_augeas('yum::setting::plugins').with({
            :incl    => '/etc/yum.conf',
            :lens    => 'Yum.lns',
            :context => '/files/etc/yum.conf/main',
            :changes => 'set plugins 1',
            :onlyif  => 'match plugins[. = 1] size == 0',
          })
        end
      end

      context "with ensure => 'present' and value => '1'" do
        let (:params) { { :ensure => 'present', :value => '1' } }

        it do
          should contain_augeas('yum::setting::plugins').with({
            :incl    => '/etc/yum.conf',
            :lens    => 'Yum.lns',
            :context => '/files/etc/yum.conf/main',
            :changes => 'set plugins 1',
            :onlyif  => 'match plugins[. = 1] size == 0',
          })
        end
      end
    end
  end

  context "with title 'cachedir'" do
    let (:title) { 'cachedir' }

    context "on osfamily RedHat" do
      let (:facts) { { :osfamily => 'RedHat' } }

      context "with value => '/var/cache/yum'" do
        let (:title) { 'cachedir' }
        let (:params) { { :value => '/var/cache/yum' } }

        it do
          should contain_augeas('yum::setting::cachedir').with({
            :incl    => '/etc/yum.conf',
            :lens    => 'Yum.lns',
            :context => '/files/etc/yum.conf/main',
            :changes => 'set cachedir /var/cache/yum',
            :onlyif  => 'match cachedir[. = /var/cache/yum] size == 0',
          })
        end
      end
    end
  end

end
