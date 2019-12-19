json.extract! event, :id, :title, :mentions, :authors, :location, :beginning_at, :facebook_id, :state, :created_at, :updated_at
json.url event_url(event, format: :json)
