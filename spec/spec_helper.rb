$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'yaml'
require 'seiun'
require File.join(File.dirname(__FILE__), 'callbacks', 'base.rb')
require File.join(File.dirname(__FILE__), 'callbacks', 'with_mock.rb')
