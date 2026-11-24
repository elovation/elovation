# -*- encoding : utf-8 -*-
%w(
  distribution
  truncated_correction
).each do |name|
  require File.expand_path(File.join(File.dirname(__FILE__), "gauss", "#{name}.rb"))
end
