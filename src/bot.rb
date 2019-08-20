require 'capybara'
require 'capybara/dsl'
require 'selenium/webdriver'

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
  end

  def register
    print 'Please enter your phone number: '
    tel_number = gets.chomp
    fill_in('inlineFormInput', with: tel_number)
    click_button('Verifizieren')

    print 'Please enter the activation code: '
    activation_code = gets.chomp
    numbers = activation_code.split('')
    numbers.each_with_index do |number, index|
      fill_in((index+1).to_s, with: number)
    end
    click_button('Verifizieren')
  end

  def run
    register
  end
end

bot = Bot.new
bot.run
