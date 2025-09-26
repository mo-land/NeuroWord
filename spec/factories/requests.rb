FactoryBot.define do
  factory :request do
    title { '修正依頼タイトル' }
    content { '修正依頼内容' }
    status { 'incompleted' }
    association :question
    association :user
  end
end