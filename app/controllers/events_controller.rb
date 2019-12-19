class EventsController < ApplicationController
  before_action :set_event, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!, only: [:new, :create, :edit, :update]

  def index
    @events = Event.order(beginning_at: :asc).group_by { |e| e.beginning_at.beginning_of_month }
  end

  def new
    @event = EventForm.new
  end

  def create
    @event = EventForm.new(event_form_params)
    @event.user = current_user

    if @event.valid?
      if @event.existing_event.present?
        redirect_to @event.existing_event, notice: 'Event already added.'
      else
        @event.save!
        redirect_to events_path, notice: 'Event was successfully created.'
      end
    else
      render :new
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_event
    @event = Event.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def event_form_params
    params.require(:event_form).permit(:title, :beginning_at, :city, :url)
  end
end
