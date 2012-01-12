class UsersController < ApplicationController
  before_filter :require_user, :only => [:edit, :update]

  def new
    redirect_to root_path, :notice => "You are already registered" if current_user

    @user = User.new
  end

  def create
    @user = User.new(params[:user])
    if @user.save
      session[:user_id] = @user.id
      redirect_to root_path, :notice => "Signed up!"
    else
      render :action => :new
    end
  rescue Stripe::StripeError => e
    logger.error e.message
    @user.errors.add :base, "There was a problem with your credit card"
    @user.stripe_token = nil
    render :action => :new
  end

  def edit
  end

  def update
    current_user.update_attributes(params[:user])
    if current_user.save
      redirect_to root_path, :notice => "Profile updated"
    else
      render :action => :edit
    end
  rescue Stripe::StripeError => e
    logger.error e.message
    @user.errors.add :base, "There was a problem with your credit card"
    @user.stripe_token = nil
    render :action => :edit
  end
end
