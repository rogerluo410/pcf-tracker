require 'net/ldap'
require 'devise/strategies/authenticatable'

module Devise
  module Strategies
    class LdapAuthenticatable < Authenticatable
      def authenticate!
        if params[:user]
          ldap = Net::LDAP.new
          ldap.host = 'scrootdc01.vmware.com' #next step the"host port base" should come fron config file
          ldap.port = 389                     #
          ldap.base= 'DC=vmware,DC=com'
          ldap.auth email, password
           
          if ldap.bind
            user = User.find_or_create_by_email(user_data)
            user_email = 'mail=' + user["email"]
            puts(user_email) 
           # init user Date
           #if ldap_user  = ldap.search(:filter => user_email).first
            if ldap_user  = ldap.search(:filter => "mail=nlai@vmware.com").first #test with nlai@
            puts ldap_user.NAME()
            puts ldap_user.SAMACCOUNTNAME()
            #puts ldap_user.inspect
            puts ldap_user.EMPLOYEENUMBER()
            puts ldap_user.MAIL()
            puts ldap_user.DEPARTMENT()
            puts ldap_user.MANAGER()
            puts ldap_user.extensionattribute10()
            # manager ?
            if ldap_user.extensionattribute10().first.to_s.split('-')[1] == "YES"
                user.admin =  true  #if the manager admin:true
                user.roles_mask = 5 # if the manager  roles_mask :5 interviewer, hiring_manager 
                puts ldap_user.directreports()
            end
            user.name=ldap_user.NAME().first.to_s
            #user.department_id =  1
            user.encrypted_password = '' 
            puts user.inspect
            if user.save 
               success!(user)
            end 
            #not find  => user.save  
            #notice  user.save  OK=> success!(user) , else =>login 
else
   puts("Fetch LDAP  Data Error!")
end
          else
            fail(:invalid_login)
          end
        end
end

#def user_signed_in? 
#
# self.user
#end

 
      def email
        params[:user][:email]
      end

      def password
        params[:user][:password]
      end

      def user_data
        {:email => email, :password => password, :password_confirmation => password}
      end
    end
  end
end

Warden::Strategies.add(:ldap_authenticatable, Devise::Strategies::LdapAuthenticatable)

