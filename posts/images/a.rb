STDIN.lines.each do |line|
  line.chomp!
  str = "mv '#{line}' '#{line.gsub(' ', '_')}'"
  #puts str
  system(str)
end
