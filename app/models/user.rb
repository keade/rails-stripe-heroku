class User < ActiveRecord::Base
  attr_accessible :name, :email, :password, :password_confirmation, :stripe_token

  attr_accessor :password, :stripe_token
  before_save :encrypt_password
  before_save :create_stripe_customer

  validates_confirmation_of :password
  validates_presence_of :password, :on => :create

  validates_presence_of :name
  validates_presence_of :email
  validates_uniqueness_of :email

  def create_stripe_customer
    if stripe_token.present?
      customer = Stripe::Customer.create(
        :description => email,
        :card => stripe_token
      )
      response = customer.update_subscription({:plan => "premium"})

      self.stripe_id = customer.id
    end
  end

  def self.authenticate(email, password)
    user = self.find_by_email(email)
    if user && user.password_hash == BCrypt::Engine.hash_secret(password, user.password_salt)
      user
    else
      nil
    end
  end


  def encrypt_password
    if password.present?
      self.password_salt = BCrypt::Engine.generate_salt
      self.password_hash = BCrypt::Engine.hash_secret(password, password_salt)
    end
  end
end
