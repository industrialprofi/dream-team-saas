FactoryBot.define do
  factory :document do
    title { Faker::Lorem.sentence(word_count: 3) }
    content { Faker::Lorem.paragraphs(number: 2).join("\n\n") }
    status { :draft }
    association :user

    trait :processing do
      status { :processing }
    end

    trait :completed do
      status { :completed }
    end

    trait :with_content do
      content { Faker::Lorem.paragraphs(number: 5).join("\n\n") }
    end
  end
end
