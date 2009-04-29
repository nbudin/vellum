class AuthNotifier < ActionMailer::Base 
  def account_activation(account, address=nil)
    if address.nil?
      address = account.person.primary_email_address
    elsif address.kind_of? EmailAddress
      address = address.address
    end
    
    @recipients = address
    @from = "noreply@#{default_url_options[:host]}"
    @subject = "Your account on #{default_url_options[:host]}"
    
    @body["name"] = account.person.name || "New User"
    @body["account"] = account
    @body["server_name"] = default_url_options[:host]
  end
  
  def generated_password(account, password, address=nil)
    if address.nil?
      address = account.person.primary_email_address
    elsif address.kind_of? EmailAddress
      address = address.address
    end
    
    @recipients = address
    @from = "noreply@#{default_url_options[:host]}"
    @subject = "Your password has been reset on #{default_url_options[:host]}"
    
    @body["name"] = account.person.name
    @body["account"] = account
    @body["server_name"] = default_url_options[:host]
    @body["password"] = password
  end
end
