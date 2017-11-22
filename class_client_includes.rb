require 'site_prism'
require 'capybara'
require 'capybara/dsl'
require 'capybara'
require 'selenium-webdriver'
require 'cloud_powers'
require 'byebug'
require 'brain_func'

module Smash
  module ClientInstanceIncludes
    def next!
      begin
        method = "#{current_state.events.first.first}"
        public_send "#{method}!"
      rescue Exception => e
        puts e
      end
    end

    def available_elements
      self.class.mapped_items.select do |mapped_element|
        begin
            public_send "has_#{mapped_element}?"
        rescue Exception => e
          puts "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!\n\n\n\ncan't find #{mapped_element}\n\n\n\n"
        end
      end
    end

    def confused; end

    def fill_out_available_fields
      buttons = []
      all_elements = available_elements
      all_elements.reject! do |el|
        begin
          if /button$/ =~ el
              buttons << el
          else
            puts "setting #{el}"
            public_send(el).set 'hey'
          end
          true
        rescue Exception => e
          puts "!!!!!!!!!!!damnit....#{e}"
          false
        end
      end

      buttons.each do |button|
        all_elements.select { |el| /button$/ !~ el }.each do |el|
          puts "(re)setting #{el}"
          public_send(el).set 'suweet'
        end
        puts "looking to click on #{button}, if it's there"
        public_send(button).click if public_send "has_#{button}?"
      end
    end

    def report
      puts "finished with #{url}"
    end
  end

  module ClientClassIncludes
    def self.extended(base)
      base.send :include, Smash::BrainFunc
    end

    attr_accessor :clues, :url

    def initialize(url, *clues)
      @url = url
      @clues = clues
    end

    # Take a set of <tt>CSV::Row</tt>s and turn them into individual
    # +elements+ on the class.
    def set_custom_elements(**clues)
      clues.each do |el_name, selector|
        public_send :element, el_name.to_sym, selector
      end
    end
  end
end
