#!/usr/bin/env ruby

require File.dirname(__FILE__) + '/../../../spec_helper'

describe "the 'accepts' function" do

  before :each do
    Puppet::Node::Environment.stubs(:current).returns(nil)
    @compiler = Puppet::Parser::Compiler.new(Puppet::Node.new("foo"))
    @scope = Puppet::Parser::Scope.new(:compiler => @compiler)
    @main = Puppet::Resource.new('stage', 'main')
  end

  it "should exist" do
    Puppet::Parser::Functions.function("accepts").should == "function_accepts"
  end

  it "should create multiple resources" do
    resources = {'foo'=>{'ensure'=>'present', 'gid'=>'1'},
                 'bar'=>{'home'=>'/home/bar', 'noop'=>true}}
    @scope.function_accepts(["user", resources])
    resources.each do |title, params|
      res = Puppet::Type.type('user').hash2resource(params.merge(:title=>title))
      @scope.catalog.resource('user', title).should == res
    end
  end

  it "should create a single resource" do
    resources = {'foo'=> {}}
    @scope.function_accepts(["user", resources])
    resources.each do |title, params|
      res = Puppet::Resource.new('user', title, params)
      @scope.catalog.resource('user', title).should == res
    end
  end

  it 'should fail if resource has title set in params' do
    resources = {'foo'=> {'title'=>'bar'}}
    lambda { @scope.function_accepts(["user", resources]) }.should raise_error(ArgumentError)
  end

  it 'should accept an empty resource hash' do
    resources = {}
    @scope.function_accepts(["user", resources])
    # should only have main stage
    @scope.catalog.resources.size.should == 1
  end

end
