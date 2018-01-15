# == Schema Information
#
# Table name: authorizations
#
#  id         :integer          not null, primary key
#  provider   :string
#  uid        :string
#  user_id    :integer
#  secret     :string
#  token      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

# an authorization is something that belongs to a user. A user may have more than one authorization,
# for e.g. facebook _and_ twitter. Some of the components of that authorization may need to be
# reset at login
class Authorization < ActiveRecord::Base
  belongs_to :user
  validates :provider, :uid, :presence => true
  

  def update_credentials!(auth_hash)

    if auth_hash.has_key? "credentials"
      updated = false
      if auth_hash["credentials"].has_key? "token"
        self.token = auth_hash["credentials"]["token"] 
        updated = true
      end

      if auth_hash["credentials"].has_key? "secret"
        self.secret = auth_hash["credentials"]["secret"] 
        updated = true
      end

      if updated
        unless self.save
          puts "Couldn't save credentials"
          self.errors.each{|attr,msg| puts "#{attr} - #{msg}" }
        end
      end
    end
  end
  
  # override the class method for find_or_create to take an OmniAuth auth_hash
  # Note that this will also create a corresponding User if one doesn't exist for this authorization
  def self.find_or_create(auth_hash, user=nil)
    # note to self: this is ActiveRecord's dynamic attribute based finder (implemented using 'method_missing')
    unless auth = find_by_provider_and_uid(auth_hash["provider"], auth_hash["uid"])
      # we couldn't find the user by provide / uuid.  Perhaps they've already signed in / set up an account
      # with their current email address
      
      email = nil
      if auth_hash["info"].has_key?("email") and not auth_hash["info"]["email"].nil? and not auth_hash["info"]["email"].empty?
        email = auth_hash["info"]["email"]
        if poss_user = find_by_email(email)
          # There is a user with this email already in the system. 
          # if it hasn't been verified, we don't want to link the two 
          # users in an authorization.  But if it has been verified, then
          # lets use the already existing user. 
          if poss_user.verified || poss_user.verified_email
            user = poss_user
          end
        end
      end
      
      # Note that info/email may be nil (e.g. Twitter)

      if user.nil? 
        user = User.create :name => auth_hash["info"]["name"] #, :role_id => Role.where(:name=>'admin').id 

        # if the provider gives an email, trust it. If not (either twitter or if facebook doesn't provide one)
        # D'oh, this doesn't work. If there is no email given, then
        # we have no email to send a confirmation to. 
        # user.skip_confirmation! unless email.nil? 
        
        # only add the email if it is not nil, b/c of the regex checker
        user.email = email.nil? ? "change@me-" + auth_hash["uid"]+ "-" + auth_hash["provider"] + ".com" : email
        user.password = Devise.friendly_token[0,20]

        # we do this here b/c this is an oath login.  If there is no email given, then
        # we have no email to send a confirmation to. 
        user.skip_confirmation! 
      end
      # puts user.inspect

        # Get the existing user by email if the provider gives us a verified email.
        # If no verified email was provided we assign a temporary email and ask the
        # user to verify it on the next step via UsersController.finish_signup
        #email_is_verified = auth.info.email && (auth.info.verified || auth.info.verified_email)
        #email = auth.info.email if email_is_verified
        #user = User.where(:email => email).first if email


      puts user.inspect

      #TODO: check this! if it isn't a successful save, then do something smart
      if user.save
        puts "User saved!"
        puts user.inspect
        auth = create :user => user, :provider => auth_hash["provider"], :uid => auth_hash["uid"],:secret => auth_hash["credentials"]["secret"],:token => auth_hash["credentials"]["token"]
        puts user.inspect
        puts auth.inspect
      else
        puts "Couldn't create user"
        user.errors.each{|attr,msg| puts "#{attr} - #{msg}" }
      end
    end
    auth.update_credentials!(auth_hash)
    auth
  end
end
