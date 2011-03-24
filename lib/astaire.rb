require 'active_support/concern'
require 'action_controller'
require 'astaire/railtie' if defined?(Rails)

module Astaire
  # Thanks Sinatra
  CALLERS_TO_IGNORE = [
    /\/astaire(\/(railtie))?\.rb$/, # all astaire code
    /lib\/tilt.*\.rb$/,    # all tilt code
    /\(.*\)/,              # generated code
    /custom_require\.rb$/, # rubygems require hacks
    /active_support/,      # active_support require hacks
  ]

  # add rubinius (and hopefully other VM impls) ignore patterns ...
  CALLERS_TO_IGNORE.concat(RUBY_IGNORE_CALLERS) if defined?(RUBY_IGNORE_CALLERS)
  
  # autoload the sub modules
  autoload :Cascade, 'astaire/cascade'
  autoload :DSL, 'astaire/dsl'
  autoload :InlineTemplates, 'astaire/inline_templates'
end