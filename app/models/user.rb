class User < ActiveRecord::Base
  attr_accessible :name, :email, :password, :password_confirmation, :stripe_token, :last_4_digits

  attr_accessor :password, :stripe_token
  before_save :encrypt_password
  before_save :create_stripe_customer

  validates_confirmation_of :password
  validates_presence_of :password, :on => :create

  validates_presence_of :name
  validates_presence_of :email
  validates_uniqueness_of :email
  validates_presence_of :last_4_digits

  def create_stripe_customer
    if stripe_token.present?
      if stripe_id.nil?
        customer = Stripe::Customer.create(
          :description => email,
          :card => stripe_token
        )
        response = customer.update_subscription({:plan => "premium"})
      else
        customer = Stripe::Customer.retrieve(stripe_id)
        customer.card = stripe_token
        customer.save
      end

      self.stripe_id = customer.id
      self.stripe_token = nil
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
