#---
# Excerpted from "Everyday Scripting in Ruby"
# We make no guarantees that this code is fit for any purpose. 
# Visit http://www.pragmaticprogrammer.com/titles/bmsft for more book information.
#---
class SubversionRepository
  def initialize(root)
    @root = root
  end

  def date(t)
    t.strftime("%Y-%m-%d")
  end

  def change_count_for(name, date)
    extract_change_count_from(log(name, date))
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

  def log(subsystem, start_date)
    File.open("svn_logs/subversion-output-#{subsystem}.txt").read
    # timespan = "--revision 'HEAD:{#{start_date}}'"
    # root = "svn://rubyforge.org/var/svn/churn-demo"
    # `svn log #{timespan} #{root}/#{subsystem}`
  end

end

def month_before(t)
  t - (28*60*60*24)
end

class Formatter

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

  # return the number in the parentheses from this string: "       ui2 **** (19)"
  def churn_line_to_int(line)
    /\((\d+)\)/.match(line)[1].to_i
    # line =~ /\((\d+)\)/
    # $1.to_i
  end

  def order_by_descending_change_count(lines)
    lines.sort do |line_a, line_b|
      line_a_count = churn_line_to_int(line_a)
      line_b_count = churn_line_to_int(line_b)
      - (line_a_count <=> line_b_count)
    end
  end

end

if $0 == __FILE__    #(1)
  subsystem_names = ['audit', 'fulfillment', 'persistence',    #(2)
                     'ui', 'util', 'inventory']
  start_date = month_before(Time.now)       #(3)
  formatter = Formatter.new
  puts formatter.header(start_date)
  repository = SubversionRepository.new('root')                   #(4)
  subsystem_lines = subsystem_names.collect do | name |
    formatter.subsystem_line(name, repository.change_count_for(name, start_date)) #(5)  
  end
  puts formatter.order_by_descending_change_count(subsystem_lines)
end
