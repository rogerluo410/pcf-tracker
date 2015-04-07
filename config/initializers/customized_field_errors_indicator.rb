ActionView::Base.field_error_proc = Proc.new do |html_tag, instance|
  if html_tag =~ /\<label/
    html_tag
  else
    errors = Array(instance.error_message).join(',')
    "<div class=\"field_with_errors\">#{html_tag} &nbsp;&nbsp;&nbsp;<span class=\"validation-error\">#{errors}</span></div>".html_safe
  end
end

