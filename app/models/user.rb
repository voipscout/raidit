require 'entity'
require 'bcrypt'

class User
  include Entity

  attr_accessor :email, :login, :password_hash, :login_tokens

  validates_presence_of :login, :email

  validate :password_hash do |record|
    record.errors.add(:password, "can't be blank") unless record.password_hash
  end

  def initialize(attrs = {})
    super

    @login_tokens ||= {}
    @onboarding = {}
  end

  ##
  # Setting a new password, gets hashed via bcrypt
  ##
  def password=(new_password)
    @password = nil

    if new_password.present?
      @password_hash = BCrypt::Password.create new_password
    end
  end

  ##
  # Return a comparison object that can be used to check
  # if two passwords match, ignoring the hashing
  ##
  def password
    @password ||= BCrypt::Password.new(@password_hash)
  end

  def set_login_token(type, token)
    @login_tokens[type] = token
  end

  def login_token(type)
    @login_tokens[type]
  end

  def onboarded!(flag)
    @onboarding[flag] = true
  end

  def requires_onboarding?(flag)
    @onboarding[flag].nil?
  end

end
