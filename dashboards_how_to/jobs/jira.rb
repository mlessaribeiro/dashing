require 'jira-ruby'

host = "http://localhost:8082/"
username = "admin"
password = "admin"
project = "ABD"
status = "Done"

options = {
            :username => username,
            :password => password,
            :context_path => '',
            :site     => host,
            :auth_type => :basic,
            use_ssl: false
          }

client = JIRA::Client.new(options)

SCHEDULER.every '5s', :first_in => 0 do |job|
  
  client = JIRA::Client.new(options)
  num = 0;

  client.Issue.jql("PROJECT = \"#{project}\" AND STATUS = \"#{status}\"").each do |issue|
      num+=1
  end
  send_event('jira', { current: num})
end