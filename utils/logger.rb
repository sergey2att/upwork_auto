# frozen_string_literal: true

class SimpleLog

  attr_accessor :progname

  def initialize(progname = '')
    @progname = progname
  end

  def info(msg)
    log('INFO', msg)
  end

  def debug(msg)
    log('DEBUG', msg)
  end

  def warning(msg)
    log('WARNING', msg)
  end

  def error(msg)
    log('ERROR', msg)
  end


  private

  def log(level, msg)
    puts("#{Time.now.strftime('%Y-%m-%d %H:%M:%S')} #{level} #{progname}: #{msg}")
  end
end