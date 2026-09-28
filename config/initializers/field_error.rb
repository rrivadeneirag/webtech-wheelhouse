# By default Rails wraps a field that has errors in a <div class="field_with_errors">,
# which breaks Bootstrap's layout. The Form Helpers guide recommends overriding
# field_error_proc so the field is rendered untouched; we add the invalid styling
# ourselves in the form partials.
Rails.application.config.action_view.field_error_proc = proc do |html_tag, _instance|
  html_tag.html_safe
end
