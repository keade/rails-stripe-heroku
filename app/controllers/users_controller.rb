class UsersController < ApplicationController
  before_filter :require_user, :only => [:edit, :update]

  def new
    redirect_to root_url, :notice => "You are already registered" if current_user

    @user = User.new
  end

  def create
    @user = User.new(params[:user])
    if @user.save
      session[:user_id] = @user.id
      redirect_to root_url, :notice => "Signed up!"
    else
      render :action => :new
    end
  rescue Stripe::InvalidRequestError => e
    logger.error e.message
    @user.errors.add :base, "There was a problem with your credit card"
    @user.stripe_token = nil
    render :action => :new
  end

  def edit
  end

  def update
    current_user.update_attributes(params[:user])
    current_user.save
    render :action => :edit
  end
end
