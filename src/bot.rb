require 'capybara'
require 'capybara/dsl'
require 'selenium/webdriver'
require './questions'

Capybara.run_server = false
# Capybara.current_driver = :selenium_chrome_headless
Capybara.current_driver = :selenium_chrome

class Bot
  include Capybara::DSL

  def initialize
    puts '--------------------'
    puts 'Energyair-Bot 2019'
    puts '--------------------'

    register
    loop { run }
  end

  def register
    visit 'https://game.energy.ch'

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

  def run
    visit 'https://game.energy.ch'

    answer_question until finished?
    return if wrong_answers?
    return register if reconfirmation_needed?

    choose_bubble

    if won?
      print 'Congratulations! You have won a ticket!'
      exit
    else
      print '\u{f44d}'
    end
  end

  private

  def answer_question
    current_question = find('.question-text').text
    answer = QUESTIONS.fetch(current_question)
    find('label', text: answer).click
    click_button('Weiter')
  end

  def finished?
    all('.question-text').empty?
  end

  def choose_bubble
    all('.circle').sample.click
  end

  def wrong_answers?
    find('h1', text: 'Leider verloren').any?
  end

  def lost?
    all('img[src=https://cdn.energy.ch/game-web/images/eair/bubble-lose.png"]').any?
  end

  def won?
    !lost?
  end

  def reconfirmation_needed?
    all('.title-verification').any?
  end

  def check_error
    if all('.error-message').any?
      warn "An error message appeared: #{find('.error-message').text}\nExiting..."
      exit
    end
  end

  private

  def check_error
    if all('.error-message').any?
      warn 'There has been an error: ' + find('.error-message').text
      print 'Exiting...'
      exit
    end
  end
end

bot = Bot.new

