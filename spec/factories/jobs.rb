FactoryBot.define do
  factory :warrior, class: Job do
    name { 'Warrior' }
  end
  factory :mage, class: Job do
    name { 'Mage' }
  end
  factory :priest, class: Job do
    name { 'Priest' }
  end
end
