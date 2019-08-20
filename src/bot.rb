require 'capybara'
require 'capybara/dsl'
require 'selenium/webdriver'
require 'questions'

Capybara.run_server = false
# Capybara.current_driver = :selenium_chrome_headless
Capybara.current_driver = :selenium_chrome

class Bot
  include Capybara::DSL

  def initialize
    puts '--------------------'
    puts 'Energyair-Bot 2019'
    puts '--------------------'

    visit('https://game.energy.ch')
    register
  end

  def register
    print 'Please enter your phone number: '
    tel_number = gets.chomp
    fill_in('inlineFormInput', with: tel_number)
    click_button('Verifizieren')

    check_error

    print 'Please enter the activation code: '
    activation_code = gets.chomp
    numbers = activation_code.split('')
    numbers.each_with_index do |number, index|
      fill_in((index + 1).to_s, with: number)
    end
    click_button('Verifizieren')
  end

  private

  def check_error
    if all('.error-message').any?
      warn "An error message appeared: #{find('.error-message').text}\nExiting..."
      exit
    end
  end
end


