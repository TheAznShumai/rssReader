class SessionsController < ApplicationController
  def create
    if params[:user]
      super
    else
      session[:guest_user_id] = User.new_guest.id
    end
  end
end
