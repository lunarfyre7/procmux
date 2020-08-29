module Procmux
  ProcEntry = Struct.new(:label, :command)
  PROC_RE = /(.*?):\s*(.*)/.freeze

  class Prox
    def initialize(procfile: nil, proclist: nil, session_name: nil)
      @session = session_name || auto_session_name
      parse_file procfile if procfile
      parse proclist if proclist
      `tmux start-server`
    end

    def run!
      attach_to_tmux! if check_tmux_session_exists

      start_tmux_session
      populate_tmux_session
      attach_to_tmux!
    end

    def auto_session_name
      "proxmux_#{File.basename(Dir.pwd).gsub(/\s/, '_')}"
    end

    def parse(proclist)
      proclist.is_a? String or raise ArgumentError, 'Proclist must be String'

      @procs = proclist.lines
              .lazy
              .map(&:chomp)
              .map { |line| ProcEntry.new(*line.match(PROC_RE)[1..2])}
    end

    def parse_file(filepath)
      parse File.open(filepath).read
    end

    def start_tmux_session
      system "tmux new-session -d -s #{@session}" or raise "Error starting Tmux session!"
    end

    def populate_tmux_session
      @procs.each_with_index do |p, i|
        if i==0
          `tmux rename-window -t 0 '#{p.label}'`
        else
          `tmux new-window -t #{@session}:#{i} -n '#{p.label}'`
        end
        `tmux send-keys -t '#{p.label}' '#{p.command}' C-m`
      end
    end

    def attach_to_tmux!
      exec "tmux attach-session -t #{@session}"
    end

    def check_tmux_session_exists
      system "tmux has -t #{@session}"
    end
  end
end
