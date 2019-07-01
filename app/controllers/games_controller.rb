require 'open-uri'
require 'json'

class GamesController < ApplicationController
  def new
    grid_size = 9
    @grid = []
    while grid_size.positive?
      @grid.push(random_letter)
      grid_size -= 1
    end
    @grid
  end

  def random_letter
    ('a'..'z').to_a[rand(26)].upcase
  end

  def score
    @start_time = Time.now
    @answer = params[:word]
    @end_time = Time.now
    @grid = params[:grid]
    @results = run_game(@answer, @grid, @start_time, @end_time)
  end

  def run_game(attempt, grid, start_time, end_time)
    # TODO: runs the game and return detailed hash of result
    if found(attempt)
      fscore = check_include(attempt, grid.split)
      time_taken = 1 / (end_time - start_time)
      finalscore = fscore * time_taken
      @result = { time: time_taken, score: fscore, message: fmessage(finalscore) }
    else
      @result = { time: time_taken, score: 0, message: 'not an english word' }
    end
      @result
  end

  def found(attempt)
    url = "https://wagon-dictionary.herokuapp.com/#{attempt}"
    word_read = open(url).read
    word = JSON.parse(word_read)
    word['found']
  end

  def fmessage(score)
    'well done' if score.positive?
    'not in the grid'
  end

  def check_include(attempt, grid)
    fscore = 0
    attempt.chars.each do |letter|
      puts letter
      if grid.include?(letter.upcase)
        grid.delete_at(grid.index(letter.upcase))
        fscore += 1
      else
        return 0
      end
    end
    fscore
  end
end
