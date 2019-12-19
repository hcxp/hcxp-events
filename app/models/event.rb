class Event < ApplicationRecord
  include AASM

  belongs_to :user

  aasm column: 'state' do
    state :new, initial: true
    state :approved
    state :rejected

    event :approve do
      transitions from: :new, to: :approved
    end

    event :reject do
      transitions from: [:new, :approved], to: :rejected
    end
  end
end
