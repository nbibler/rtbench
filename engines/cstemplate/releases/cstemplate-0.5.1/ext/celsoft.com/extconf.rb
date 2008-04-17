# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software

require 'mkmf'
require 'rbconfig'

unless respond_to? :try_compile then
  class << self
    alias try_compile try_link
  end
end

def msg_check(s)
  print s, "... "
  STDOUT.flush
end

def have_ruby_func(s)
  oldlibs = $libs
  oldlibpath = $LIBPATH
  $libs += " " + Config::CONFIG['LIBRUBYARG']
  $LIBPATH = [$libdir, $archdir] | $LIBPATH
  begin
    have_func s, 'ruby.h'
  rescue ArgumentError   # for ruby-1.4
    have_func s
  ensure
    $libs = oldlibs
    $LIBPATH = oldlibpath
  end
end


dir_config 'template'


defines = []

#~ have_ruby_func 'rb_block_given_p'       # for ruby-1.4

msg_check 'checking for kind of operating system'
os_code = with_config('os-code') ||
  case RUBY_PLATFORM.split('-',2)[1]
    when 'amigaos' then
      os_code = 'AMIGA'
    when /\Aos2[-_]emx\z/ then
      os_code = 'OS2'
    when 'mswin32', 'mingw32' then
      os_code = 'WIN32'
    else
      os_code = 'UNIX'
  end

os_code = 'OS_' + os_code.upcase

OS_NAMES = {
  'OS_MSDOS'   => 'MS-DOS',
  'OS_AMIGA'   => 'Amiga',
  'OS_VMS'     => 'VMS',
  'OS_UNIX'    => 'Unix',
  'OS_ATARI'   => 'Atari',
  'OS_OS2'     => 'OS/2',
  'OS_MACOS'   => 'MacOS',
  'OS_TOPS20'  => 'TOPS20',
  'OS_WIN32'   => 'Win32',
  'OS_VMCMS'   => 'VM/CMS',
  'OS_ZSYSTEM' => 'Z-System',
  'OS_CPM'     => 'CP/M',
  'OS_QDOS'    => 'QDOS',
  'OS_RISCOS'  => 'RISCOS',
  'OS_UNKNOWN' => 'Unknown',
}
unless OS_NAMES.key? os_code then
  puts "invalid OS_CODE `#{os_code}'"
  exit
end
puts OS_NAMES[os_code]
defines << "OS_CODE=#{os_code}"

unless enable_config('transitional', true) then
  defines << 'TRANSITIONAL=0'
end

defines = defines.collect{|d|' -D'+d}.join
if $CPPFLAGS then
  $CPPFLAGS += defines
else
  $CFLAGS += defines
end

create_makefile('template')
