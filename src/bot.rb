require 'capybara'
require 'capybara/dsl'
require 'selenium/webdriver'
require 'terminal-notifier'
require './questions'

Capybara.run_server = false

class Bot
  include Capybara::DSL

  def initialize()
    puts '--------------------'
    puts 'Energyair-Bot 2019'
    puts '--------------------'

    Capybara.current_driver = :selenium_chrome
    register
    loop { run }
  end

  def register
    visit 'https://game.energy.ch'

    print "\nPlease enter your phone number: "
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

    if reconfirmation_needed?
      TerminalNotifier.notify('Reconfirmation needed!', title: 'energyair-bot')
      return register
    end

    choose_bubble

    if lost?
      print '.'
    else
      puts "\nCongratulations! You have won a ticket!"
      TerminalNotifier.notify('Congratulations! You have won a ticket!', title: 'energyair-bot')
      sleep
    end
  end

  private

  def answer_question
    current_question = find('.question-text').text
    answer = QUESTIONS.fetch(current_question)
    2.times { find('label', text: answer).click }
    sleep rand(1..2)
    click_on 'Weiter'
  end

  def finished?
    all('.question-text').empty?
  end

  def choose_bubble
    all('.circle').sample.click
    sleep rand(1..2)
  end

  def wrong_answers?
    all('h1').map(&:text).include?('Leider verloren')
  end

  def lost?
    all('img[src="https://cdn.energy.ch/game-web/images/eair/bubble-lose.png"]').any?
  end

  def reconfirmation_needed?
    all('.title-verification').any?
  end

  def check_error
    if all('.error-message').any?
      warn "An error message appeared: #{find('.error-message').text}\nExiting..."
      TerminalNotifier.notify('An error message appeared!', title: 'energyair-bot')
      exit
    end
  end
end

bot = Bot.new
