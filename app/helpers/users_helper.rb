module UsersHelper
  def gravatar_for(user, options = { :size => 50 })
    email = user.email
    email.downcase! unless email.nil?
    gravatar_image_tag(email, :alt => user.name,
                                            :class => 'gravatar',
                                            :gravatar => options)
  end

  # These three methods are used to make devise functions available
  # outside the devise controllers. 
  # http://stackoverflow.com/questions/4081744/devise-form-within-a-different-controller
  def resource_name
    :user
  end

  def resource
    @resource ||= User.new
  end

  def devise_mapping
    @devise_mapping ||= Devise.mappings[:user]
  end
end
