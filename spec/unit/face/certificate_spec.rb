#!/usr/bin/env rspec
require 'spec_helper'
require 'puppet/face'

require 'puppet/ssl/host'

describe Puppet::Face[:certificate, '0.0.1'] do
  include PuppetSpec::Files
  it "should have a ca-location option" do
    subject.should be_option :ca_location
  end

  it "should set the ca location when invoked" do
    Puppet::SSL::Host.expects(:ca_location=).with(:foo)
    Puppet::SSL::Host.indirection.expects(:save)
    subject.sign "hello, friend", :ca_location => :foo
  end

  it "(#7059) should set the ca location when an inherited action is invoked" do
    Puppet::SSL::Host.expects(:ca_location=).with(:foo)
    subject.indirection.expects(:find)
    subject.find "hello, friend", :ca_location => :foo
  end

  describe '#generate' do
    it "should only save one csr" do
      require 'puppet/ssl/certificate_request'
      Puppet[:ssldir] = tmpdir('ssl')
      Puppet::SSL::Host.expects(:ca_location=).with(:foo)
      Puppet::SSL::CertificateRequest.indirection.expects(:save).once
      subject.generate('node_name', :ca_location => :foo)
    end
  end
end
