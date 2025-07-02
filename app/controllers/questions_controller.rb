class QuestionsController < ApplicationController
  def index
    @questions = Question.includes(:user)
  end

  def new
    @question = Question.new
  end
end
