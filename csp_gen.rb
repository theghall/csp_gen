# csp_gen.rb
#
require 'byebug'

directives = {:default => '', :font => '', :frame_src => '', :img => '', :script => '', :stylej => ''}

def get_error_type(line)
  errors = %w{font frame image script stylesheet}
  directive_index = {:default => :default, :font => :font, :frame => :frame_src, :image => :image, :stylesheet => :stylesheet, :script => :script}

  error_type = :unknown

  errors.each do |error|
    if line.include?(error)
      error = "default" if line.include?("inline")

      error_type = directive_index[error.to_sym]
      break
    end
  end

  error_type
end

def parse_error(line)
  type = get_error_type(line)
  puts(">>>#{type}<<<") 
end

File.open('csp_error.txt','r') do |csp_file|

  while line = csp_file.gets
    line.chomp!.strip!
    puts line
    parse_error(line.chomp) unless line == ''
  end
end

