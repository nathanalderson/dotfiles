import Config

# set this to `:debug` to enable spammy Ecto query logs
config :persistence, TangoTango.Persistence.Repo, log: false

defmodule MyConsoleLogger do
  # verbose log format
  def logs_format do
    "\n#{IO.ANSI.inverse()}$time [$level]#{IO.ANSI.inverse_off()}\n#{IO.ANSI.faint()}$metadata#{IO.ANSI.normal()}\n$message\n"
  end

  # single-line log format. Works best with limited or no metadata
  # def logs_format do
  #  "#{IO.ANSI.inverse()}$time [$level]#{IO.ANSI.inverse_off()} #{IO.ANSI.faint()}$metadata#{IO.ANSI.normal()} $message\n"
  # end

  # def logs_metadata, do: []
  # def logs_metadata, do: [:file, :line]
  def logs_metadata, do: :all

  def format(level, message, timestamp, metadata) do
    # This inserts a string in the logs that you can ctrl-click to jump to
    file = metadata[:file]
    line = metadata[:line]
    metadata = if file && line, do: metadata |> Keyword.put(:loc, " #{file}:#{line}"), else: metadata

    compiled_pattern = Logger.Formatter.compile(logs_format())
    Logger.Formatter.format(compiled_pattern, level, message, timestamp, metadata)
  rescue
    e -> "\ncould not format: #{inspect({level, message, metadata})}\n#{inspect(e)}\n"
  end
end

config :logger, :default_formatter,
  format: {MyConsoleLogger, :format},
  colors: [enabled: true],
  metadata: MyConsoleLogger.logs_metadata()

# Uncomment this to use prod-style logs (replaces paragraph above)
# config :logger, :default_handler, formatter: {TangoTango.Core.CustomLogFormatter, metadata: :all}

# Uncomment this paragraph to write prod-style json logs to a file
# Must also add `Logger.add_handlers(:core)` to `apps/core/lib/core/application.ex`
config :core, :logger, [
  {:handler, :file_log, :logger_std_h,
   %{
     config: %{
       file: ~c"/home/nathan/tmp/stillhouse-logs.jsonl"
     },
     formatter: {TangoTango.Core.CustomLogFormatter, metadata: :all}
   }}
]

# Import custom secrets
if File.exists?("#{__DIR__}/dev.custom.secret.exs") do
  import_config "dev.custom.secret.exs"
end

config :persistence, TangoTango.Persistence.ExternalEvents.TimeZoneLookup.DetsCacheLoader, enabled: true
