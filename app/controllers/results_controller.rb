class ResultsController < ApplicationController
  def new
    @result = Result.new
  end
end
