require 'tempfile'

describe '`few` command' do
  before do
    @few = File.dirname(__FILE__) + '/../bin/few'
  end

  it 'shows help with -h option' do
    `#{@few} -h`.should match(/USAGE/)
  end

  it 'shows version with -v option' do
    `#{@few} -v`.should match(/\d\.\d\.\d/)
  end

  it 'updates itself with --selfupdate option' do
    # In other words: $ few --selfupdate
    t = Tempfile.new('few').path + '.rb'
    File.open(t, 'w') {|io|
      io.puts 'def open(*o, &b); p o; "#!\np 1"; end'
      io.puts 'def require(*o);end'
      io.puts 'def File.open(*o); end'
      io.puts 'def system(*o); end'
      io.puts 'load "bin/few"'
    }
    `ruby #{t} --selfupdate`.strip.should ==
      '["http://github.com/ujihisa/few/raw/master/bin/few"]'
  end

  it 'opens the HTML flavored data given by pipe on your browswer' do
    # In other words: $ cat FILE | few
    t = Tempfile.new('few').path + '.rb'
    File.open(t, 'w') {|io|
      io.puts 'def system(*o); p o; end'
      io.puts 'load "bin/few"'
    }
    cmd, arg = *eval(`echo 123 | ruby #{t}`)
    cmd.should == case RUBY_PLATFORM
                  when /darwin/
                    'open'
                  when /mswin(?!ce)|mingw|cygwin|bccwin/
                    'start'
                  else
                    'firefox'
                  end
    arg.should match(/\.html$/)
    File.read(arg).should match('123')
  end

  it 'opens the HTML flavored data given by parameter on your browswer' do
    # $ few FILE
    t = Tempfile.new('few').path + '.rb'
    u = Tempfile.new('few2').path + '.txt'
    File.open(t, 'w') {|io|
      io.puts 'def system(*o); p o; end'
      io.puts 'load "bin/few"'
    }
    File.open(u, 'w') {|io|
      io.puts 'hi'
      io.puts '  vi'
      io.puts 'yay  yay'
    }
    cmd, arg = *eval(`ruby #{t} #{u}`)
    cmd.should == case RUBY_PLATFORM.downcase
                  when /linux/
                    if ENV['KDE_FULL_SESSION'] == 'true'
                      'kfmclient'
                    elsif ENV['GNOME_DESKTOP_SESSION_ID']
                      'gnome-open'
                    elsif system("exo-open -v >& /dev/null")
                      'exo-open'
                    else
                      'firefox'
                    end
                  when /darwin/
                    'open'
                  when /mswin(?!ce)|mingw|bccwin/
                    'start'
                  else
                    'firefox'
                  end
    arg.should match(/\.html$/)

    l = open(arg,'r').readlines
    l[13].chomp.should match('hi')
    l[14].chomp.should match('  vi')
    l[15].chomp.should match('yay  yay')
  end

  it 'also accepts --filetype= option' do
    pending # based on the last specification
  end

  it 'should --tee option runs like to `tee` command' do
    pending
  end
end
