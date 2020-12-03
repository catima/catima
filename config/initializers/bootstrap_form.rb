# Monkey patch to allow a block to be passed to #select.

require "bootstrap_form/version"
# unless BootstrapForm::VERSION == "2.7.0"
#   fail "Monkey patch hasn't been tested with #{BootstrapForm::VERSION}"
# end

require "bootstrap_form/form_builder"
module BootstrapForm
  class FormBuilder < ActionView::Helpers::FormBuilder
    def select(method, choices, options={}, html_options={}, &block)
      form_group_builder(method, options, html_options) do
        select_without_bootstrap(method, choices, options, html_options, &block)
      end
    end
  end
end
