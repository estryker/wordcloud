module ApplicationHelper
 def bootstrap_class_for flash_type
    puts "flash type " + flash_type
    case flash_type.to_s
    when 'success'
      "alert-success"
    when 'error'
      "alert-danger"
    when 'alert'
      "alert-warning"
    when 'notice'
      "alert-info"
    else
      "alert-" + flash_type.to_s
    end
 end

 # This is to allow controllers to access this in a controlled way without polluting their namespace
 # using helpers.anonymous_email
 def anonymous_email
   "anonymous@notarealdomainbutiputithereanyways.com"
 end
 def anonymous_user
   User.where(email: anonymous_email).first
 end
 
  
end
