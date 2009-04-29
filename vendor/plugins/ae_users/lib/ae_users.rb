# AeUsers
require 'active_record'

module AeUsers
  begin
    @@db_name = Rails::Configuration.new.database_configuration["users"]["database"]
    def self.db_name
      @@db_name
    end
  rescue
  end
  
  @@signup_allowed = true
  def self.signup_allowed?
    @@signup_allowed
  end

  def self.disallow_signup
    @@signup_allowed = false
  end
  
  @@permissioned_classes = []
  def self.add_permissioned_class(klass)
    if not @@permissioned_classes.include?(klass.name)
      @@permissioned_classes.push(klass.name)
    end
  end
  
  def self.permissioned_classes
    return @@permissioned_classes.collect do |name|
      eval(name)
    end
  end
  
  def self.permissioned_class(name)
    if @@permissioned_classes.include?(name)
      return eval(name)
    end
  end
  
  @@cache_permissions = true
  begin
    PermissionCache.count
  rescue
    @@cache_permissions = false
  end
  
  def self.cache_permissions?
    @@cache_permissions
  end
  
  @@js_framework = "prototype"
  def self.js_framework
    @@js_framework
  end
  
  def self.js_framework=(framework)
    @@js_framework = framework
  end

  # yeah, the following 2 functions are Incredibly Evil(tm).  I couldn't find any other way
  # to pass around an ActiveRecord class without having it be potentially overwritten on
  # association access.
  def self.profile_class
    nil
  end

  def self.profile_class=(klass)
    module_eval <<-END_FUNC
      def self.profile_class
        return #{klass.name}
      end
    END_FUNC
  end

  def self.map_openid(map)
    map.open_id_complete 'auth', :controller => "auth", :action => "login", :requirements => { :method => :get }
  end
  
  module Acts
    module Permissioned
      def self.included(base)
        base.extend ClassMethods
      end

      module ClassMethods
        def acts_as_permissioned(options = {})
          has_many :permissions, :as => :permissioned, :dependent => :destroy

          cattr_accessor :permission_names
          self.permission_names = options[:permission_names] || [:show, :edit, :destroy]
          self.permission_names = self.permission_names.collect do |perm|
            perm.to_s
          end
          if not self.permission_names.include? "change_permissions"
            self.permission_names.push "change_permissions"
          end

          self.permission_names.each do |perm|
            define_method("permit_#{perm}?") do |person|
              self.permitted?(person, perm)
            end
          end
          
          AeUsers.add_permissioned_class(self)

          extend AeUsers::Acts::Permissioned::SingletonMethods
          include AeUsers::Acts::Permissioned::InstanceMethods
        end
      end

      module SingletonMethods
      end

      module InstanceMethods
        def permitted?(person, permission=nil)
          person.permitted? self, permission
        end
        
        def permitted_people(permission)
          grants = permissions.find_all_by_permission(permission)
          people = []
          grants.collect {|grant| grant.grantee}.each do |grantee|
            if grantee.kind_of? Person
              if not people.include? grantee
                people << grantee
              end
            elsif grantee.kind_of? Role
              grantee.people.each do |person|
                if not people.include? person
                  people << person
                end
              end
            end
          end
          return people
        end

        def grant(grantees, permissions=nil)
          if not grantees.kind_of?(Array)
            grantees = [grantees]
          end

          if not permissions.kind_of?(Array)
            if permissions.nil?
              permissions = self.class.permission_names
            else
              permissions = [permissions]
            end
          end

          grantees.each do |grantee|
            if grantee.kind_of? Role
              permissions.each do |perm|
                if AeUsers.cache_permissions?
                  PermissionCache.destroy_all(["permissioned_type = ? and permissioned_id = ? and permission_name = ?", self.class.name, self.id, perm])
                end
                Permission.create :role => grantee, :permission => perm, :permissioned => self
              end
            elsif grantee.kind_of? Person
              permissions.each do |perm|
                if AeUsers.cache_permissions?
                  PermissionCache.destroy_all(["person_id = ? and permissioned_type = ? and permissioned_id = ? and permission_name = ?", grantee.id, self.class.name, self.id, perm])
                end
                Permission.create :person => grantee, :permission => perm, :permissioned => self
              end
            end
          end
        end

        def revoke(grantees, permissions=nil)
          if not grantees.kind_of?(Array)
            grantees = [grantees]
          end

          if not permissions.kind_of?(Array)
            if permissions.nil?
              permissions = self.class.permission_names
            else
              permissions = [permissions]
            end
          end

          grantees.each do |grantee|
            permissions.each do |perm|
              existing = if grantee.kind_of? Role
                if AeUsers.cache_permissions?
                  PermissionCache.destroy_all(["permissioned_type = ? and permissioned_id = ? and permission_name = ?", self.class.name, self.id, perm])
                end
                Permission.find_by_role_and_permission_type(grantee, perm)
              elsif grantee.kind_of? Person
                if AeUsers.cache_permissions?
                  PermissionCache.destroy_all(["person_id = ? and permissioned_type = ? and permissioned_id = ? and permission_name = ?", grantee.id, self.class.name, self.id, perm])
                end
                Permission.find_by_person_and_permission_type(person, perm)
              end

              if existing
                existing.destroy
              end
            end
          end
        end
      end
    end
  end

  module ControllerExtensions
    module RequirePermission
      def self.included(base)
        base.extend ClassMethods
      end

      def access_denied(msg=nil, options={})
        options = {
          :layout => active_layout
        }.update(options)
        msg ||= "Sorry, you don't have access to view that page."
        if logged_in?
          body = "If you feel you've been denied access in error, please contact the administrator of this web site."
        else
          body = "Try logging into an account."
        end
        @login = Login.new(:email => cookies['email'])
        render options.update({:inline => "<h1>#{msg}</h1>\n\n<div id=\"login\"><p><b>#{body}</b></p><%= render :partial => 'auth/auth_form' %></div>"})
      end
      
      def logged_in?
        if session[:person]
          begin
            return Person.find(session[:person])
          rescue ActiveRecord::RecordNotFound
            return nil
          end
        elsif session[:account]
          begin
            acct = Account.find(session[:account])
            session[:person] = acct.person.id
            return acct.person
          rescue ActiveRecord::RecordNotFound
            return nil
          end
        elsif attempt_login_from_params
          return logged_in?
        else
          return nil
        end
      end
    
      def logged_in_person
        return logged_in?
      end
      
      def attempt_login(login)
        @account = Account.find_by_email_address(login.email)
        if not @account.nil? and not @account.active
          redirect_to :controller => 'auth', :action => :needs_activation, :account => @account, :email => login.email, :return_to => login.return_to
          return false
        elsif not @account.nil? and @account.check_password login.password
          if (not AeUsers.profile_class.nil? and not @account.person.nil? and 
            AeUsers.profile_class.find_by_person_id(@account.person.id).nil?)

            session[:provisional_person] = @account.person.id
            redirect_to :controller => 'auth', :action => :needs_profile, :return_to => login.return_to
            return false
          else
            session[:person] = @account.person.id
            return true
          end
        else
          flash[:error_messages] = ['Invalid email address or password.']
          return false
        end
      end
      
      def attempt_open_id_login(return_to)
        if return_to
          session[:return_to] = return_to
        else
          return_to = session[:return_to]
        end
        
        openid_url = params[:openid_url]
        params.delete(:openid_url)
        
        optional_fields = Person.sreg_map.keys
        if AeUsers.profile_class and AeUsers.profile_class.respond_to?('sreg_map')
          optional_fields += AeUsers.profile_class.sreg_map.keys
        end
        authenticate_with_open_id(openid_url, :optional => optional_fields) do |result, identity_url, registration|
          if result.successful?
            id = OpenIdIdentity.find_by_identity_url(identity_url)
            if not id.nil?
              @person = id.person
            end
            if id.nil? or @person.nil?
              if AeUsers.signup_allowed?
                session[:identity_url] = identity_url
                redirect_to :controller => 'auth', :action => :needs_person, :return_to => return_to, :registration => registration.data
                return false
              else
                flash[:error_messages] = ["Sorry, you are not registered with this site."]
                return false
              end
            else
              if (not AeUsers.profile_class.nil? and AeUsers.profile_class.find_by_person_id(@person.id).nil?)
                session[:provisional_person] = @person.id
                redirect_to :controller => 'auth', :action => :needs_profile, :return_to => return_to
                return false
              else
                session[:person] = @person.id
                return true
              end
            end
          else
            flash[:error_messages] = result.message
            return false
          end
        end
        return session[:person]
      end
      
      def attempt_ticket_login(secret)
        t = AuthTicket.find_ticket(secret)
        if t.nil?
          flash[:error_messages] = ["Ticket not found"]
          return false
        else
          session[:person] = t.person
          t.destroy
          return session[:person]
        end
      end
      
      def attempt_login_from_params
        return_to = request.request_uri
        if not params[:ae_email].blank? and not params[:ae_password].blank?
          login = Login.new(:email => params[:ae_email], :password => params[:ae_password], :return_to => return_to)
          attempt_login(login)
        elsif not params[:openid_url].blank?
          attempt_open_id_login(return_to)
        elsif not params[:ae_ticket].blank?
          attempt_ticket_login(params[:ae_ticket])
        end
      end
      
      def do_permission_check(obj, perm_name, fail_msg)
        attempt_login_from_params
        p = logged_in_person
        if not (p and p.permitted?(obj, perm_name))
          access_denied fail_msg
        end
      end

      module ClassMethods
        def require_login(conditions = {})
          before_filter conditions do |controller|
            if not controller.logged_in?
              controller.attempt_login_from_params
              if not controller.logged_in?
                controller.access_denied "Sorry, but you need to be logged in to view that page."
              end
            end
          end
        end

        def require_class_permission(perm_name, conditions = {})
          delegated = false
          if conditions[:class_name]
            cn = conditions[:class_name]
            delegated = true
          elsif conditions[:class_param]
            cpn = conditions[:class_param]
          end
          before_filter conditions do |controller|
            if cn.nil? and cpn
              cn = controller.params[cpn]
              delegated = true
            end
            controller_cn = controller.class.name.gsub(/Controller$/, "").singularize
            cn ||= controller_cn
            full_perm_name = "#{perm_name}_#{cn.tableize}"
            if delegated
              msg = "Sorry, but you are not permitted to #{perm_name} #{controller_cn.tableize.humanize.downcase} in this #{cn.tableize.humanize.singularize.downcase}."
            else
              msg = "Sorry, but you are not permitted to #{perm_name} #{cn.tableize.humanize.downcase}."
            end
            controller.do_permission_check(nil, full_perm_name, msg)
          end
        end

        def require_permission(perm_name, conditions = {})
          if conditions[:class_name]
            cn = conditions[:class_name]
          end
          id_param = conditions[:id_param] || :id
          before_filter conditions do |controller|
            cn ||= controller.class.name.gsub(/Controller$/, "").singularize
            o = eval(cn).find(controller.params[id_param])
            if not o.nil?
              controller.do_permission_check(o, perm_name, "Sorry, but you are not permitted to #{perm_name} this #{cn.tableize.singularize.humanize.downcase}.")
            end
          end
        end

        def rest_edit_permissions(options = {})
          options = {
            :restrict_create => false,
          }.update(options)
          restrict_create = options[:restrict_create]
          options.delete(:restrict_create)
          require_permission("edit", { :only => [:edit, :update] }.update(options))
          if restrict_create
            require_class_permission("create", { :only => [:new, :create] }.update(options))
          end
          require_permission("destroy", { :only => [:destroy] }.update(options))
        end

        def rest_view_permissions(options = {})
          options = {
            :restrict_list => false,
          }.update(options)
          restrict_list = options[:restrict_list]
          options.delete(:restrict_list)
          if restrict_list
            require_class_permission("list", { :only => [:index] }.update(options))
          elsif options[:class_name]
            require_permission("show", { :only => [:index], :id_param => "#{options[:class_name].tableize}_id" }.update(options))
          end
          require_permission("show", { :only => [:show] }.update(options))
        end

        def rest_permissions(options = {})
          rest_view_permissions(options)
          rest_edit_permissions(options)
        end
      end
    end
  end

  module HelperFunctions
    def permission_names(item)
      if item.kind_of? ActiveRecord::Base
        return item.class.permission_names
      else
        return item.permission_names
      end
    end
    
    def full_permission_name(item, perm)
      if item.kind_of? ActiveRecord::Base
        return perm
      else
        return "#{perm}_#{item.class.name.tableize}"
      end
    end
    
    def permission_grants(item, perm)
      if item.kind_of? ActiveRecord::Base
        grants = item.permissions.find_all_by_permission(perm)
      else
        full_perm_name = full_permission_name(item, perm)
        grants = Permission.find(:all, :conditions => ["permission = ?", full_perm_name])
      end
      return grants
    end
    
    def all_permitted?(item, perm)
      sql = "permission = ? and (role_id = 0 or role_id is null) and (person_id = 0 or person_id is null)"
      return Permission.find(:all, :conditions => [sql, full_permission_name(item, perm)]).length > 0
    end
    
    def logged_in?
      return controller.logged_in?
    end
    
    def logged_in_person
      return controller.logged_in_person
    end
    
    def app_profile(person = nil)
      if person.nil?
        person = logged_in_person
      end

      AeUsers.profile_class.find_by_person_id(person.id)
    end
    
    def user_picker(domid, options = {})
      options = {
        :people => true,
        :roles => false,
        :callback => nil
      }.update(options)
      
      rhtml = text_field_tag("#{domid}_shim", "", { :style => "width: 15em; display: inline; float: none;" })
      rhtml << hidden_field_tag("#{domid}", "")
      auto_complete_url = url_for(:controller => "permission", :action => "auto_complete_for_permission_grantee",
                                  :people => options[:people], :roles => options[:roles], :escape => false)
      
      if AeUsers.js_framework == "prototype"
        rhtml << <<-ENDRHTML
<div id="#{domid}_shim_auto_complete" class="auto_complete"></div>
<%= auto_complete_field('#{domid}_shim', :select => "grantee_id", :param_name => "q",
    :after_update_element => "function (el, selected) { 
        kid = el.value.split(':');
        klass = kid[0];
        id = kid[1];
        cb = function(klass, id) {
          $('#{domid}').value = el.value;
          $('#{domid}_shim').value = '';
          #{options[:callback]}
        };
        cb(klass, id);
      }",
    :url => "#{auto_complete_url}") %>
ENDRHTML
      elsif AeUsers.js_framework == "jquery"
        rhtml << <<-ENDRHTML
<script type="text/javascript">
$(function() {
  jq_domid = "\##{domid.gsub(/(\W)/, '\\\\\\\\\1')}";
  $(jq_domid + "_shim").autocomplete('#{auto_complete_url}',
      {
        formatItem: function(data, i, n, value) {
          return value;
        },
      }).bind('result', function(e, data) {
        $(jq_domid).val(data[1]);
        #{options[:callback]}
      }
   );
});
</script>
ENDRHTML
      end
      
      render :inline => rhtml
    end
  end
end
