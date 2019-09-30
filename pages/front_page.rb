# frozen_string_literal: true

require_relative 'base_page'
require_relative '../lib/asserts'

#
# Front page
#
class FrontPage < BasePage

  SEARCH_BOX = { name: 'q' }.freeze

  # TODO: must be moved to separate module 'Header' for reusing on any page
  def search_for(search_type, search_term)
    find_last(SEARCH_BOX).send_keys ''
    find_last(css: '.dropdown-toggle.btn.p-xs-left-right').click
    driver.find_elements(css: 'ul.sc-up-header-search-menu li')
          .filter { |e| e.text != '' }
          .select { |e| e.text == search_type }
          .first.click
    find_last(SEARCH_BOX).send_keys search_term
    driver.find_elements(css: '.navbar-form .input-group-btn button')
          .filter { |e| e.text == 'Submit search' }
          .first.click
  end

end
