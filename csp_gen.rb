# csp_gen.rb
#
require 'byebug'

DIRECTIVES = {:default_src => "'none'", :font_src => '', :child_src => '', \
              :img_src => '', :script_src => '', :style_src => '', \
              :base_uri => "'self'", :connect_src => "'self'", :form_action => "'self'", \
              :frame_ancestors => "'self'", :object_src => "'self'", \
              :plugin_types => 'application/pdf', :report_uri => "'self'", :sandbox => "'self'"}

def get_error_type(line)
  # Spaces will be around that which is refused
  errors = [" font ", " frame ", " image ", " script ", " style"]
  directive_index = {:font => :font_src, :frame => :child_src, \
                     :image => :img_src, :style => :style_src, \
                     :script => :script_src}

  error_type = :unknown
 
  errors.each do |error|
    if line.include?(error)
      error_type = directive_index[error.strip.to_sym]
      break
    end
  end

  error_type
end

def shorten_inlinkz_thumb(line)
  return line unless line.include?('inlinkz.com/thumbs')

  split = line.split('/')

  split[0..3].join('/') + '/'
end

def get_filename(line, domain)
  if line.include?('inline')
    filename = '\'unsafe-inline\''
  elsif line.include?(domain)
    filename = '\'self\''
  else
    # the first '' enclosed text should be the filename
     split = line.split('\'')

    # :TODO Strip Querys from end of filenames
    filename = shorten_inlinkz_thumb(split[1])
  end
end

def has_non_file_option(file)
  options = ['*', 'deny', 'none', 'unsafe-inline', 'self']

  found = false

  options.each do |opt|
    found = file.include?(opt)
    break if found
  end
  
  found
end

def parse_error(line, domain, ofn)
  type = get_error_type(line)
  
  if type != :default
    if type != :unknown
      file = get_filename(line, domain)
      if !has_non_file_option(file)
        DIRECTIVES[type] << file + '; ' unless DIRECTIVES[type].include?(file)
      else
        # Easier to see directives at start
        byebug if DIRECTIVES[type].nil?
        DIRECTIVES[type].prepend(file + '; ') unless DIRECTIVES[type].include?(file)
      end
    end
  else
    # handle default_src
  end
end

def gen_csp_policy(ofn)
  File.open(ofn, 'w') do |csp_file|

    dir_spacing = ' ' * 4
    opt_spacing = ' ' * 6

    csp_file.puts('Header set Content-Security-Policy-Report-Only "\\')

    DIRECTIVES.each_key do |key|
      file_options = DIRECTIVES[key]

      split = file_options.split(';')

      # hash key cannot have '-' in it
      csp_file.puts(dir_spacing + "#{key.to_s.gsub('_','-')}" + " \\")

      split[0..-2].each do |fopt|
        csp_file.puts(opt_spacing + fopt + " \\") 
      end

      csp_file.puts(opt_spacing + split[-1] + "; \\")
    end

    csp_file.puts(opt_spacing + '"')
  end
end

domain = ARGV[0]
ifn = ARGV[1]
ofn = ARGV[2]

File.open(ifn,'r') do |csp_file|

  while line = csp_file.gets
    line.chomp!.strip!
    puts line
    parse_error(line, domain, ofn) unless line == ''
  end

  gen_csp_policy(ofn)
end

byebug
p DIRECTIVES
