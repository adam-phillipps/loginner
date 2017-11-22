require 'brain_func'
require 'cloud_powers'
require 'cloud_powers/stubs/aws_stubs'
require 'byebug'
require 'uri'
require_relative './client_class_builder'

module Smash
  module CheaterStuff

    include Smash::BrainFunc
    include Smash::CloudPowers
    include Smash::CloudPowers::Queue
    include Smash::CloudPowers::Zenv

    Capybara.register_driver :chrome do |app|
      Capybara::Selenium::Driver.new(app, :browser => :chrome)
    end
    Capybara.configure do |config|
      config.default_driver = :chrome
    end
    Capybara.current_driver = :chrome
    Capybara.javascript_driver = :chrome
    Capybara.save_and_open_page_path = '/Users/adam.phillipps/code/ft_fe/local/results'
    Capybara.page.driver.browser.manage.window.size = Selenium::WebDriver::Dimension.new(1620,1024)

    def workflow_description
      {
        workflow: {
          states: [
            { new: {
                event: :get_clues,
                transitions_to: :getting_clues
              }
            },
            { getting_clues: {
                event: :organize_clues,
                transitions_to: :organizing_clues
              }
            },
            { organizing_clues: {
                event: :build_client,
                transitions_to: :building_client
              }
            },
            { building_client: {
                event: :deploy_client,
                transitions_to: :deploying_client
              }
            },
            { deploying_client: {
                event: :gather_results,
                transitions_to: :getting_clues
              }
            },
            { gathering_results: {
                event: :send_results,
                transitions_to: :organizing_clues
              }
            },
            { done: nil }
          ]
        }
      }
    end

    # These are because the csv sucks
    def cheater_clues
      @cheater_clues ||= [
        {
          url: 'https://homebank.psecu.com/Login/Login.aspx',
          username: "input[name='AccountNumber']",
          password: "input[name='Pwd']",
          login_button: "input[name='btnLogin']",
          pin: "input[name='Pin']",
          test_encode: "input[name='txtEncodedPassword']"
        },
        {
          url: 'https://www.rbfcu.org/NBO/loginSubmit.do',
          username: "input[name='username']",
          password: "input[name='password']",
          login_button: "input[name='Go']"
        },
        {
          url: 'http://www.bbt.com/',
          login_dropdown_togler_button: '#login-dropdown-toggler',
          username: "input['UserName']",
          password: "input[name='Password']",
          login_button: "#logon"
        },
        {
          url: 'https://online.bankofthewest.com/BOW/Login.aspx',
          username: "input[name='ctlSignon$UserIdTextBox']",
          password: "input[name='ctlSignon$PasswordTextBox']",
          login_button: "input[name='ctlSignon$LogOnButton']"
        },
        {
          url: 'https://google.com',
          username: "input[name='username']",
          password: "input[name='password']",
          login_button: "input[name='login']"
        },
        {
          url: 'https://google.com',
          username: "input[name='uname']",
          password: "input[name='pword']",
          login_button: "input[name='submit']"
        }
      ]
    end

    def client_workflow_description
      {
        workflow: {
          states: [
            { new: {
                event: :load,
                transitions_to: :loading
              }
            },
            { loading: {
                event: :fill_out_available_fields,
                transitions_to: :filling_out_avaialbe_fields
              }
            },
            { filling_out_avaialbe_fields: {
                event: :submit,
                transitions_to: :submitting
              }
            },
            { submitting: {
                event: :report,
                transitions_to: :reporting
              }
            },
            { reporting: {
                event: :confused,
                transitions_to: :done
              }
            },
            { done: nil }
          ]
        }
      }
    end
  end
end
