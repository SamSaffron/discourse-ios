# -*- coding: utf-8 -*-
$:.unshift("/Library/RubyMotion/lib")
require 'motion/project/template/ios'

begin
  require 'bundler'
  Bundler.require
rescue LoadError
end

Motion::Project::App.setup do |app|
  # Use `rake config' to see complete project settings.
  app.name = 'discourse-ios'

  app.info_plist['UILaunchStoryboardName'] = 'Launch Screen'

  app.fonts << 'OpenSans-Light.ttf'

  app.frameworks << 'WebKit'
end
