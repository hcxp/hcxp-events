class EventForm
  include ActiveModel::Model

  attr_accessor :url, :title, :city, :beginning_at, :user

  validates :title, presence: true
  validates :url, presence: true
  validates :city, presence: true
  validates :beginning_at, presence: true
  validates :user, presence: true

  def save!
    Event.create!(
      title: title,
      city: city,
      beginning_at: beginning_at,
      facebook_id: id_from_url,
      user: user
    )
  end

  def existing_event
    @existing_event ||= Event.find_by(facebook_id: id_from_url)
  end

  private

  def id_from_url
    url.match(%r{(http:\/\/|https:\/\/)?(www.)?facebook.com\/events\/(\d+)})[3]
  end
end
