class BugReportsController < ApplicationController
  def new
    @bug_report = BugReport.new
  end
  
  def create
    @bug_report = BugReport.new(bug_report_params)

    if @bug_report.save
      flash["messages"] = ["Bug Reported Successfully!" + (@bug_report.requires_response ? " We will reach out as soon as possible." : "")] 
      redirect_to root_url
    else
      flash.now["errors"] = @bug_report.errors.full_messages
      render :new
    end
  end

  private

  def bug_report_params
    params.require(:bug_report).permit(:body, :requires_response, :user)
  end
end
