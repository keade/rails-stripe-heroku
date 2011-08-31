class User < ActiveRecord::Base
  attr_accessible :name, :email, :password, :password_confirmation, :stripe_token, :last_4_digits

  attr_accessor :password, :stripe_token
  before_save :encrypt_password
  before_save :update_stripe

  validates_confirmation_of :password
  validates_presence_of :password, :on => :create

  validates_presence_of :name
  validates_presence_of :email
  validates_uniqueness_of :email
  validates_presence_of :last_4_digits

  def update_stripe
    if stripe_token.present?
      if stripe_id.nil?
        customer = Stripe::Customer.create(
          :description => email,
          :card => stripe_token
        )
        self.last_4_digits = customer.active_card.last4
        response = customer.update_subscription({:plan => "premium"})
      else
        customer = Stripe::Customer.retrieve(stripe_id)
        customer.card = stripe_token
        customer.save
        self.last_4_digits = customer.active_card.last4
      end

      self.stripe_id = customer.id
      self.stripe_token = nil
    elsif last_4_digits_changed?
      self.last_4_digits = last_4_digits_was
    end
  end

  def self.authenticate(email, password)
    user = self.find_by_email(email)
    if user && BCrypt::Password.new(user.hashed_password) == password
      user
    else
      nil
    end
  end


  def encrypt_password
    if password.present?
      self.hashed_password = BCrypt::Password.create(password)
    end
  end
end
