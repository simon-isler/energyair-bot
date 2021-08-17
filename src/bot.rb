require 'capybara'
require 'capybara/dsl'
require 'selenium/webdriver'
require_relative 'game'

Capybara.run_server = false

class Bot
  include Capybara::DSL

  def initialize(headless: true, access_token:)
    puts '--------------------'
    puts Game::TITLE
    puts '--------------------'

    @headless = headless
    @access_token = access_token
  end

  def run
    Capybara.current_driver = @headless ? :selenium_chrome_headless : :selenium_chrome
    authenticate_user
    play_game
  end

  private

  def authenticate_user
    visit Game::URL
    browser = Capybara.current_session.driver.browser
    browser.manage.add_cookie(name: 'access_token', value: @access_token)
  end

  def play_game
    loop do
      start_game
      answer_questions until finished?
      return if wrong_answers?

      choose_bubble
      if game_lost?
        print "."
      else
        puts 'Congratulations! You have won a ticket! 🎉'
        break
      end
    end
  end

  def start_game
    visit Game::URL
    click_button('Game starten')
  end

  def answer_questions
    current_question = find('.question-text').text
    answer = Game::QUESTIONS.fetch(current_question)
    sleep rand(0.5..1)
    find('label', text: answer).click
    sleep rand(0.75..1.5)
    click_button('Weiter')
  end

  def finished?
    all('.question-text').empty?
  end

  def wrong_answers?
    all('h1').map(&:text).include?('Leider verloren')
  end

  def choose_bubble
    click_button('Jetzt Tickets für das Energy Air gewinnen!')
    sleep rand(0.75..1.5)
    all('.circle').sample.click
  end

  def game_lost?
    all('img[src="https://cdn.energy.ch/game-web/images/eair/bubble-lose.png?2021"]').any?
  end
end
