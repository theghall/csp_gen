# csp_gen.rb
#
require 'byebug'

DIRECTIVES = {:default_src => '', :font_src => '', :frame_src => '', :img_src => '', :script_src => '', :style_src => ''}

def get_error_type(line)
  errors = %w{font frame image inline script stylesheet}
  directive_index = {:inline => :default_src, :font => :font_src, :frame => :frame_src, :image => :img_src, :stylesheet => :style_src, :script => :script_src}

  error_type = :unknown
 
  errors.each do |error|
    if line.include?(error)
      error_type = directive_index[error.to_sym]
      break
    end
  end

  error_type
end

def get_filename(line)
  # the first '' enclosed text should be the filename
  split = line.split('\'')

  filename = split[1]
end

def parse_error(line)
  type = get_error_type(line)
  
  if type != :default
    if type != :unknown
      file = get_filename(line)
      DIRECTIVES[type] << file + '; '
    end
  else
    # handle default_src
  end
end

fn = ARGV[0]

File.open(fn,'r') do |csp_file|

  while line = csp_file.gets
    line.chomp!.strip!
    puts line
    parse_error(line) unless line == ''
  end
end

