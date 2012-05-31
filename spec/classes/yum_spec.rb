#!/usr/bin/env rspec

require 'spec_helper'

describe 'yum' do
  it { should contain_class 'yum' }
end
