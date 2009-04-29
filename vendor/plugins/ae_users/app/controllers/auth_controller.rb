class AuthController < ApplicationController
  unloadable
  filter_parameter_logging :password
  
  def login
    @login = Login.new(params[:login])
    @login.email ||= cookies['email']
    params[:openid_url] ||= cookies['openid_url']
    if @login.return_to.nil? or @login.return_to == ""
      if params[:return_to]
        @login.return_to = params[:return_to]
      else
        @login.return_to = request.env["HTTP_REFERER"]
      end
    end
    if using_open_id? or (request.post? and not logged_in?)
      result = if using_open_id?
        attempt_open_id_login(@login.return_to)
      else
        attempt_login(@login)
      end
      if result
        if @login.remember and @login.remember != 0
          if using_open_id?
            cookies['openid_url'] = params[:openid_url]
          else
            cookies['email'] = @login.email
          end
        end
        if @login.return_to
          redirect_to @login.return_to
        elsif session[:return_to]
          rt = session[:return_to]
          session[:return_to] = nil
          redirect_to rt
        else
          redirect_to '/'
        end
      elsif using_open_id?
        @openid_url = params[:openid_url]
      end
    end
  end
  
  def needs_person
    @open_id_identity = OpenIdIdentity.find_or_create_by_identity_url(session[:identity_url])
    @person = Person.new
    if not AeUsers.profile_class.nil?
      @app_profile = AeUsers.profile_class.send(:new, :person => @person)
    end
    
    if params[:registration]
      person_map = HashWithIndifferentAccess.new(Person.sreg_map)
      profile_map = if AeUsers.profile_class and AeUsers.profile_class.respond_to?("sreg_map")
        HashWithIndifferentAccess.new(AeUsers.profile_class.sreg_map)
      else
        nil
      end
        
      params[:registration].each_pair do |key, value|
        if key == 'email'
          params[:email] = value
        elsif person_map.has_key?(key.to_s)
          mapper = person_map[key]
          attrs = mapper.call(value)
          @person.attributes = attrs
        elsif (profile_map and profile_map.has_key?(key))
          mapper = profile_map[key]
          @app_profile.attributes = mapper.call(value)
        end
      end
    end
    if params[:person]
      @person.attributes = params[:person]
    end
    if params[:app_profile] and @app_profile
      @app_profile.attributes = params[:app_profile]
    end
    
    if request.post?
      error_messages = []
      error_fields = []
      
      ["firstname", "lastname", "gender"].each do |field|
        if not @person.send(field)
          error_fields.push field
          error_messages.push "You must enter a value for #{field}."
        end
      end
      
      if not params[:email]
        error_fields.push("email")
        error_messages.push "You must enter a value for email."
      end
      
      if error_messages.length > 0
        flash[:error_fields] = error_fields
        flash[:error_messages] = error_messages
      else
        @person.save
        @person.primary_email_address = params[:email]
        @open_id_identity.person = @person
        @open_id_identity.save
        if @app_profile
          @app_profile.save
        end
        
        session[:person] = @person
        redirect_to session[:return_to]
      end
    end
  end

  def auth_form  
    respond_to do |format|
      format.js { render :layout => false }
    end
  end
  
  def auth_form  
    respond_to do |format|
      format.js { render :layout => false }
    end
  end
  
  def needs_profile
    @person = Person.find session[:provisional_person]
    if @person.nil?
      flash[:error_messages] = ["Couldn't find a person record with that ID.  
        Something may have gone wrong internally.  Please try again, and if the problem persists, please contact
        the site administrator."]
      redirect_to :back
    end
    
    if not AeUsers.signup_allowed?
      flash[:error_messages] = ['Your account is not valid for this site.']
      redirect_to "/"
    else
      if not AeUsers.profile_class.nil?
        @app_profile = AeUsers.profile_class.send(:new, :person_id => session[:provisional_person])
        @app_profile.attributes = params[:app_profile]
        
        if request.post?
          @app_profile.save
          session[:person] = @person
          redirect_to params[:return_to]
        end
      end
    end
  end
  
  def forgot
    ActionMailer::Base.default_url_options[:host] = request.host
    
    @account = Account.find_by_email_address(params[:email])
    if not @account.nil?
      @account.generate_password
    else
      flash[:error_messages] = ["There's no account matching that email address.  Please try again, or sign up for an account."]
      redirect_to :action => :forgot_form
    end
  end
  
  def resend_validation
    ActionMailer::Base.default_url_options[:host] = request.host
    
    @email_address = Account.find params[:email]
    if not @email_address.nil?
      @email_address.generate_validation
    else
      flash[:error_messages] = ["Email address #{params[:email]} not found!"]
      redirect_to "/"
    end
  end
  
  def logout
    reset_session
    redirect_to request.env["HTTP_REFERER"]
  end
end
