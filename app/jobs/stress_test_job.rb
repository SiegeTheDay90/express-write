class StressTestJob < ApplicationJob
    queue_as :default
  
    
    def perform(number)
        start = Time.now
        sleep(rand(3..8))
        finish = Time.now
        logger.debug("Job #{number} complete @ #{Time.now} in #{finish - start} seconds. \n")
    end
  end
  