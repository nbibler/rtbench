module RTBench
  
  # Overrides the default Logger formatting to report severity and timestamps
  # in ISO 8601 formatting (in UTC).
  #
  class Formatter < Logger::Formatter
    def call(severity, timestamp, progname, msg)
      sprintf("%s %-5s - %s\n", timestamp.utc.strftime("%Y-%m-%d %H:%M:%S"), severity, msg)
    end
  end
  
end