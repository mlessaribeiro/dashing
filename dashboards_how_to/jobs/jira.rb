require 'jira-ruby'
# require_relative'../project_api'
# require_relative '../dashboard_config'

JIRA_URL = URI.parse("http://localhost:8080")

def getJiraOptions(username, password)
  jira_user_options = {
    :username => username,
    :password => password,
    :context_path => JIRA_URL.path,
    :site => "http://localhost:8080",
    :auth_type => :basic,
    :ssl_verify_mode => OpenSSL::SSL::VERIFY_NONE,
    :use_ssl => JIRA_URL.scheme == 'https' ? true : false,
    :proxy_address => nil,
    :proxy_port => nil
  }
  return jira_user_options
end

# def getJiraUserProjects(username, password)

#   jira_user_options = getJiraOptions(username, password)
#   client = JIRA::Client.new(jira_user_options)
#   result = Array.new

#   allProjects = getProjects
#   userProjects = client.Project.all;

#   userProjects.each do |project|
#     if allProjects.has_key? project.key then
#       result.push(project.key)
#     end
#   end

#   return result;
# end

SCHEDULER.every '20s', :first_in => 0 do |job|

  userName = "admin"#getDashboardConfiguration["jira-name"]
  password = "admin"#getDashboardConfiguration["jira-password"]
  jira_options = getJiraOptions(userName, password)
  client = JIRA::Client.new(jira_options)

  q = {
    'allTasks'        => "issuetype = \"Task\""
    # 'alphaTest'        => "issuetype = \"Task\" AND status in (\"To Do\")"
  }
  q.each do |eventName, query|
    # passing :max_results == 0 returns json['total']
    # see: https://github.com/sumoheavy/jira-ruby/blob/master/lib/jira/resource/issue.rb#L79
    query_options = {
      :max_results => 0
    }
    current_number_issues = client.Issue.jql(query, query_options)
    send_event(eventName+"_"+project_key, { value: current_number_issues })
  end

end
