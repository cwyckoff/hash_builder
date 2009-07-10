require 'rubygems'
require 'spec'
require 'ruby-debug'
$:.unshift(File.dirname(__FILE__) + '/../lib')
require 'hash_builder'

alias :running :lambda
