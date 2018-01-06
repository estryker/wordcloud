
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
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :omniauthable,  omniauth_providers: [:facebook, :twitter, :istherea]
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
