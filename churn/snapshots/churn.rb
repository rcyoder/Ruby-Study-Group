#---
# Excerpted from "Everyday Scripting in Ruby"
# We make no guarantees that this code is fit for any purpose. 
# Visit http://www.pragmaticprogrammer.com/titles/bmsft for more book information.
#---
def month_before(t)
  t - (28*60*60*24)
end

def header(d)
#  "Changes since " + d.strftime("%Y-%m-%d")+":"
#  "Changes since #{d.strftime("%Y-%m-%d")}:"
#  d.strftime("Changes since %Y-%m-%d:")'
"Changes since #{d}:"
end

def asterisks_for(n)
  '*'.*((n/5.0).round)   #return n/5 asterisks, rounded up or down
end

def subsystem_line(name, count)
  "#{name.rjust(14)} #{asterisks_for(count)} (#{count})"
end

def change_count_for(name)
  extract_change_count_from(svn_log(name))
end

def svn_date(t)
  t.strftime("%Y-%m-%d")
end

def extract_change_count_from(log_text)
  lines = log_text.split("\n")
#  dashed_lines = lines.find_all do | line |
#    line.include?('--------')
#  end 
  dashed_lines = lines.find_all { |line| line.include?('--------') }
  raise Exception if dashed_lines.length < 1
  dashed_lines.length-1
end

def svn_log(subsystem, start_date)
#  File.open("subversion-output.txt").read
  timespan = "--revision 'HEAD:{#{start_date}}'"
  root = "svn://rubyforge.org/var/svn/churn-demo"
  `svn log #{timespan} #{root}/#{subsystem}`
end

if $0 == __FILE__    #(1)
  subsystem_names = ['audit', 'fulfillment', 'persistence',    #(2)
                     'ui', 'util', 'inventory']
  start_date = month_before(Time.now)       #(3)

  puts header(start_date)                   #(4)
  subsystem_names.each do | name |
    puts subsystem_line(name, change_count_for(name)) #(5)  
  end
end
