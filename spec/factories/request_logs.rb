FactoryBot.define do
  factory :request_log do
    prompt { Faker::Lorem.sentence(word_count: 10) }
    response { Faker::Lorem.paragraphs(number: 3).join("\n\n") }
    tokens_used { Faker::Number.between(from: 50, to: 500) }
    association :user
    association :document

    trait :expensive do
      tokens_used { Faker::Number.between(from: 1000, to: 2000) }
    end

    trait :cheap do
      tokens_used { Faker::Number.between(from: 10, to: 100) }
    end
  end
end
