class AccountController < ApplicationController
  unloadable
  require_login :only => [:edit_profile, :edit_email_addresses, :change_password, :add_openid, :delete_openid]
  before_filter :check_signup_allowed, :only => [:signup, :signup_success]
  
  filter_parameter_logging :password
  
  def activate
    if logged_in?
      redirect_to "/"
      return
    end

    @account = Account.find params[:account]

    if not @account.nil? and @account.activation_key == params[:activation_key]
      @account.active = true
      @account.activation_key = nil
      @account.save
    else
      redirect_to :action => :activation_error
    end
  end
  
  def edit_profile
    @person = logged_in_person
    if not AeUsers.profile_class.nil?
      @app_profile = AeUsers.profile_class.find_by_person_id(@person.id)
    end
    
    if request.post?
      @person.update_attributes params[:person]
      if @app_profile
        @app_profile.update_attributes params[:app_profile]
      end
    end
  end
  
  def edit_email_addresses
    errs = []
    
    if params[:new_address] and params[:new_address].length > 0
      existing_ea = EmailAddress.find_by_address params[:new_address]
      if existing_ea
        errs.push "A different person is already associated with the email address you tried to add."
      else
        newea = EmailAddress.create :person => logged_in_person, :address => params[:new_address]
        if params[:primary] == 'new'
          newea.primary = true
          newea.save
        end
      end
    end
    
    if params[:primary] and params[:primary] != 'new'
      id = params[:primary].to_i
      if id != 0
        addr = EmailAddress.find id
        if addr.person != logged_in_person
          errs.push "The email address you've selected as primary belongs to a different person."
        else
          addr.primary = true
          addr.save
        end
      else
        errs.push "The email address you've selected as primary doesn't exist."
      end
    end
    
    if params[:delete]
      params[:delete].each do |id|
        addr = EmailAddress.find id
        if addr.person != logged_in_person
          errs.push "The email address you've selected to delete belongs to a different person."
        elsif addr.primary
          errs.push "You can't delete your primary email address.  Try making a different email address your primary address first."
        else
          addr.destroy
        end
      end
    end
    
    if errs.length > 0
      flash[:error_messages] = errs
    end
    
    redirect_to :action => :edit_profile
  end
  
  def change_password
    password = params[:password]
    if password[:password1].nil? or password[:password2].nil?
      redirect_to :action => :edit_profile
    elsif password[:password1] != password[:password2]
      flash[:error_messages] = ["The passwords you entered don't match.  Please try again."]
      redirect_to :action => :edit_profile
    else
      acct = logged_in_person.account
      acct.password = password[:password1]
      acct.save
    end
  end
  
  def activation_error
  end
  
  def signup_success
  end
  
  def add_openid
    if using_open_id?
      authenticate_with_open_id(params[:openid_url]) do |result, identity_url|
        if result.successful?
          id = OpenIdIdentity.find_by_identity_url(identity_url)
          if id.nil?
            id = OpenIdIdentity.new :person => logged_in_person, :identity_url => identity_url
          else
            if id.person.nil?
              id.person = logged_in_person
            elsif id.person != logged_in_person
              flash[:error_messages] = ["That OpenID belongs to a different person (#{id.person.name})."]
              return
            end
          end
          if not id.save
            flash[:error_messages] = id.errors.collect { |e| e[0].humanize + " " + e[1] }
          end
        else
          flash[:error_messages] = [result.message]
        end
        redirect_to :action => 'edit_profile'
      end
    else
      flash[:error_messages] = ["Please enter an OpenID url."]
    end
  end
  
  def delete_openid
    id = OpenIdIdentity.find(params[:id])
    if id.person == logged_in_person
      if logged_in_person.account or logged_in_person.open_id_identities.length > 1
        id.destroy
      else
        flash[:error_messages] = ["Deleting that OpenID would leave you no way of logging in!"]
      end
    else
      flash[:error_messages] = ["That OpenID does not belong to you!"]
    end
    redirect_to :action => 'edit_profile'
  end
  
  def signup
    @account = Account.new(:password => params[:password1])
    @person = Person.new(params[:person])
    @addr = EmailAddress.new :address => params[:email], :person => @person, :primary => true
    @person.account = @account
    
    if not AeUsers.profile_class.nil?
      @app_profile = AeUsers.profile_class.send(:new, :person => @person)
      @app_profile.attributes = params[:app_profile]
    end
        
    if request.post?
      error_fields = []
      error_messages = []
    
      if Person.find_by_email_address(params[:email])
        error_fields.push "email"
        error_messages.push "An account at that email address already exists!"
      end
    
      if params[:password1] != params[:password2]
        error_fields += ["password1", "password2"]
        error_messages.push "Passwords do not match."
      elsif params[:password1].length == 0
        error_fields += ["password1", "password2"]
        error_messages.push "You must enter a password."
      end
    
      ["firstname", "lastname", "email", "gender"].each do |field|
        if (not params[field] or params[field].length == 0) and (not params[:person][field] or params[:person][field].length == 0)
          error_fields.push field
          error_messages.push "You must enter a value for #{field}."
        end
      end
      
      if error_fields.size > 0 or error_messages.size > 0
        flash[:error_fields] = error_fields
        flash[:error_messages] = error_messages
      else
        @account.save
        @addr.save
        @person.save
        if @app_profile
          @app_profile.save
        end
    
        begin
          ActionMailer::Base.default_url_options[:host] = request.host
          @account.generate_activation
        rescue
          @account.activation_key = nil
          @account.active = true
          @account.save
          redirect_to :action => :signup_noactivation
          return
        end
      
        redirect_to :action => :signup_success
      end
    end
  end
  
  private  
  def check_signup_allowed
    if not AeUsers.signup_allowed?
      access_denied "Account signup is not allowed on this site."
    end
  end
end
