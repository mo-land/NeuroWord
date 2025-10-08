module FindQuestion
  extend ActiveSupport::Concern

  private

  def set_question
    @question = Question.includes(origin_words: :related_words).find(params[:id])
  end
end
