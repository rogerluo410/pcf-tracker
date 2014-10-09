require 'xmlrpc/client'
module ApplicationHelper

  # Return the full title on a per-page basis
  def full_title(page_title)
    base_title = 'Pcf_Tracker'
    if page_title.empty?
      base_title
    else
      "#{base_title} | #{page_title}"
    end
  end

  def sortable(model_name, column, title=nil)
    title ||= column.titleize
    css_class = column == sort_column(model_name) ? "current #{sort_direction}" : nil
    direction = column == sort_column(model_name) && sort_direction == 'asc' ? 'desc' : 'asc'
    link_to title, {:sort => column, :direction => direction}, {:class => css_class, :field => column }
  end

  def sort_column(model_name)
    model_name.constantize.column_names.include?(params[:sort]) ? params[:sort] : 'updated_at'
  end

  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : 'asc'
  end

  def current_page(path)
    "current" if current_page?(path)
  end

  def flash_class(level)
    case level
      when :notice then 'alert alert-success'
      when :success then 'alert alert-success'
      when :error then 'alert alert-error'
      when :alert then 'alert alert-error'
    end
  end
 
  def search_scotzilla(name,version,category)
      puts name,version,category
      client = XMLRPC::Client.new2(Rails.application.config.server_scotzilla)
      client.instance_variable_get(:@http).instance_variable_set(:@verify_mode, OpenSSL::SSL::VERIFY_NONE)
      # workaround for https://bugs.ruby-lang.org/issues/8182
      # will be fixed in ruby 2.2.0
      client.http_header_extra = {"accept-encoding" => "identity"}
 
      proxy = client.proxy('SCOTzilla')
 
      params = {  name: name, version: version, category: category}

      result = proxy.find_master(params)
     
      return result
    end

  def search_scotzilla_baseos(name,version,category,target)
      puts name,version,category
      client = XMLRPC::Client.new2(Rails.application.config.server_scotzilla)
      client.instance_variable_get(:@http).instance_variable_set(:@verify_mode, OpenSSL::SSL::VERIFY_NONE)
      # workaround for https://bugs.ruby-lang.org/issues/8182
      # will be fixed in ruby 2.2.0
      client.http_header_extra = {"accept-encoding" => "identity"}

      proxy = client.proxy('SCOTzilla')

      params = {  name: name, version: version, category: category, gb_target: target}

      result = proxy.find_master(params)

      return result
    end


    def file_ut(product_name,product_version,mt_id,username,password)
       client = XMLRPC::Client.new2(Rails.application.config.server_scotzilla,"",360)
       client.instance_variable_get(:@http).instance_variable_set(:@verify_mode, OpenSSL::SSL::VERIFY_NONE)
       client.http_header_extra = {"accept-encoding" => "identity"}
       proxy = client.proxy('SCOTzilla')
       result = Hash.new
       #query in scotzilla first
       puts 'query in scotzilla first'
       params_qry = { product: product_name, version: product_version, mte: mt_id }
       result_qry = proxy.find_requests(params_qry)
       if result_qry['stat'] == 'err'
       puts 'Query failed'
       params = { product: product_name, version: product_version, mte: mt_id ,interaction: [ 'Distributed - Calling Existing Classes' ], description: 'This a package for product '+product_name , username: username , password: password  } 
       puts params
       result_crt = proxy.create_request(params)  
       puts result_crt
       result = {stat: result_crt['stat'], id: result_crt['id'] }
       else
       puts 'Through query...'
       array = result_qry['requests']
       puts array[0]['id']
       result ={stat: result_qry['stat'], id: array[0]['id']} 
       puts result       
       end
       return result
       rescue StandardError => stdErr
        result_err = {stat: 'err',msg: mt_id}
       return  result_err
    end


   def extract_ruby(name)
       puts name
       exact_name = ''
       exact_version = '' 

       #stack 1
       stack1_top = 0
       stack1 = []
       #stack 2
       stack2_top = 0
       stack2 = []

       flag = 0 #switch 
       for i in (0...name.length)
         if flag == 0  #extract exact name
          if /[0-9a-zA-Z]/.match(name[i]) !=nil or ( (name[i]=="-" or name[i]=="_" ) and /[0-9a-zA-Z]/.match(name[i+1]) != nil)
            stack1[stack1_top] = name[i]
            stack1_top=stack1_top+1
          else
             flag = 1 #switch to extract version
          end
            
         else #extract exact version 
          if /.*[=]+/.match(name) != nil
               for j in(i...name.length)
                  if name[j] == '='
                    m = j+1
                    for k in(m...name.length)
                       if name[k] == ','
                            break
                       end
                       if /[0-9a-zA-Z]/.match(name[k]) != nil or (name[k]=='.' and /[0-9a-zA-Z]/.match(name[k+1]) != nil)
                                 stack2[stack2_top] = name[k]
                                 stack2_top=stack2_top+1
                       end
                    end #end for...
                    break
                   end #end if name[j]=='='
               end #end  for j in(i,name.length)
              break 
          else
            if /[0-9a-zA-Z]/.match(name[i]) != nil or (name[i]=='.' and /[0-9a-zA-Z]/.match(name[i+1]) != nil)
                     stack2[stack2_top] = name[i] 
                     stack2_top=stack2_top+1
            end
          end
         end
       end

    exact_name = stack1[0...stack1_top].join("")
    exact_version = stack2[0...stack2_top].join("")
    if exact_name.length == 0 
      exact_name =nil
    end
    if exact_version.length == 0 
      exact_version =nil
    end
    exact_couple =[exact_name,exact_version]
    return exact_couple    
    end #end function


    def extract_java(name)

     #name='jackson-core-asl,1.6.2'
      name1 = name.split(',')

      exact_couple = [ name1[0],name1[1] ]

      return exact_couple
    end

    def extract_go(name)

     #name='gouuid,bcd29efdea6dde845e4146e0b347d15df3a23957'
      name1 = name.split(',')

      exact_couple = [ name1[0],name1[1] ]

      return exact_couple
    end

    def extract_linux(name)

    #name='name,version'
     name1 = name.split(',')

     exact_couple = [name1[0],name1[1]]

     return exact_couple
    end


end
