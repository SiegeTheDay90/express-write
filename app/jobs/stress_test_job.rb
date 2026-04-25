# frozen_string_literal: true

class StressTestJob < ApplicationJob
  queue_as :default

  def perform(number)
    start = Time.now
    sleep(1)
    finish = Time.now
    logger.info("Job #{number} complete @ #{Time.now} in #{(finish - start).round(4)} seconds. \n")
  end
end
