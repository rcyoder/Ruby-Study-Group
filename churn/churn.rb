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
  
  def initialize
    @subsystem_array = []
  end

  def use_date(start_date)
    @start_date = start_date
  end

  def header
    #  "Changes since " + d.strftime("%Y-%m-%d")+":"
    #  "Changes since #{d.strftime("%Y-%m-%d")}:"
    #  d.strftime("Changes since %Y-%m-%d:")'
    "Changes since #{@start_date}:"
  end

  def asterisks_for(n)
    '*'.*((n/5.0).round)   #return n/5 asterisks, rounded up or down
  end

  def subsystem_line(name, count)
    "#{name.rjust(14)} #{asterisks_for(count)} (#{count})"
  end

  # Sort our array of line info [name, count] by the count
  def order_by_descending_change_count(data)
    data.sort do |a, b|
        count1 = a.last
        count2 = b.last
      - (count1 <=> count2)
    end
  end
  
  def use_subsystem_with_change_count(name, count)
    @subsystem_array << [name, count]
  end
  
  def to_text
    output = [header]
    order_by_descending_change_count(@subsystem_array).each do |element|
      name = element.first
      count = element.last
      output << subsystem_line(name, count)
    end
    output
  end

end

if $0 == __FILE__    #(1)
  subsystem_names = ['audit', 'fulfillment', 'persistence',    #(2)
                     'ui', 'util', 'inventory']
  start_date = month_before(Time.now)       #(3)
  formatter = Formatter.new
  formatter.use_date(start_date)
  repository = SubversionRepository.new('root')                   #(4)
  subsystem_names.collect do | name |
    formatter.use_subsystem_with_change_count(name, repository.change_count_for(name, start_date)) #(5)  
  end
  puts formatter.to_text
end
