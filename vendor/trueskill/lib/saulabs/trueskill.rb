# -*- encoding : utf-8 -*-
require 'pp'

require File.expand_path(File.join(File.dirname(__FILE__), "gauss.rb"))

%w(
  base 
  greater_than
  likelihood
  prior
  weighted_sum
  within
).each do |name|
  require File.expand_path(File.join(File.dirname(__FILE__), "trueskill", "factors", "#{name}.rb"))
end

%w(
  base 
  iterated_team_performances
  performances_to_team_performances
  prior_to_skills
  skills_to_performances
  team_difference_comparision
  team_performance_differences
).each do |name|
  require File.expand_path(File.join(File.dirname(__FILE__), "trueskill", "layers", "#{name}.rb"))
end

%w(
  base
  loop
  sequence
  step
).each do |name|
  require File.expand_path(File.join(File.dirname(__FILE__), "trueskill", "schedules", "#{name}.rb"))
end

%w(
  rating
  factor_graph
  score_based_bayesian_rating
).each do |name|
  require File.expand_path(File.join(File.dirname(__FILE__), "trueskill", "#{name}.rb"))
end
