class QuestionsController < ApplicationController
  def index
    @questions = Question.includes(:user)
  end
end
