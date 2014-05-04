class FeedsController < ApplicationController
  respond_to :json

  def index
    @feeds = Feed.all
    respond_with @feeds
  end

  def show
    @feed = Feed.where(:id => params[:id]).first
    respond_with @feed
  end

  def create
    @feed = Feed.create(feed_params)
    respond_with @feed
  end

  def update
    @feed = Feed.update(params[:id], feed_params)
    respond_with @feed
  end

  def delete
    @feed = Feed.destroy(params[:id])
  end

  private

  def feed_params
    params.require(:feed).permit(:name, :url)
  end
end
