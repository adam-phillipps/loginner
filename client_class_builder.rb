require 'csv'
require 'site_prism'
require 'capybara'
require 'capybara/dsl'
require 'capybara'
require 'selenium-webdriver'
require 'cloud_powers'
require 'byebug'
require 'brain_func'
require_relative './class_client_includes'

module Smash
  module ClientClassBuilder
    def self.build_client(clues, workflow)
      page =
        Class.new(SitePrism::Page) do |new_page|
          new_page.extend Smash::ClientClassIncludes
          new_page.send :include, Smash::ClientInstanceIncludes

          new_page.set_url clues.delete(:url) || clues.delete('url')
          new_page.set_custom_elements **clues
        end.new

      page.inject_workflow(workflow)
      page
    end
  end
end
