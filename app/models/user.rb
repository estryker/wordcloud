
# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  reset_password_token   :string
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0), not null
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :string
#  last_sign_in_ip        :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  provider               :string
#  uid                    :string
#  name                   :string
#  role_id                :integer
#  confirmation_token     :string
#  confirmed_at           :datetime
#  confirmation_sent_at   :datetime
#  unconfirmed_email      :string
#

class User < ApplicationRecord
  extend Devise::Models
  has_many :responses
  has_many :surveys
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  # Note: we need an email domain and to setup something like MailGun to make the emails verifiable.
  #       If it becomes a problem, just only use facebook / twitter logins
  devise :database_authenticatable, :registerable, 
         :recoverable, :rememberable, :trackable, :validatable,
         :omniauthable,  omniauth_providers: [:facebook, :twitter, :istherea]

  TEMP_EMAIL_REGEX = /\Achange@me/

  user_role_id = 2 # Role.where(name: 'user').first.id
  attribute :role_id, :integer, default: user_role_id
  def add_provider(auth_hash)
    # Check if the provider already exists, so we don't add it twice
    auth = nil
    if auth = authorizations.find_by_provider_and_uid(auth_hash["provider"], auth_hash["uid"])
      auth.update_credentials!(auth_hash)
    else
      auth = Authorization.find_or_create(auth_hash, self)
      # Authorization.create :user => self, :provider => auth_hash["provider"], :uid => auth_hash["uid"]
    end
    auth
  end

  def admin?
     self.role_id == Role.where(:name => 'admin').first.id
  end

  def email_verified?
    self.email && self.email !~ TEMP_EMAIL_REGEX
  end

end
