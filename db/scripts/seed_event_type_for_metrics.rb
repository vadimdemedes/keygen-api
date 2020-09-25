# heroku run -e BATCH_SIZE=1000000 rails runner db/scripts/seed_event_type_for_metrics.rb

BATCH_SIZE = ENV.fetch('BATCH_SIZE') { 1_000 }.to_i
batch = 0

puts "[scripts.seed_event_type_for_metrics] Starting"

loop do
  batch += 1
  count = Metric.connection.update("
    UPDATE
      metrics AS m
    SET
      event_type_id = e.id
    FROM
      event_types AS e
    WHERE
      m.metric = e.event AND
      m.id IN (
        SELECT
          id
        FROM
          metrics m2
        WHERE
          m2.event_type_id IS NULL
        LIMIT
          #{BATCH_SIZE}
      )
  ")

  puts "[scripts.seed_event_type_for_metrics] Updated #{count} metric rows (batch ##{batch})"

  break if count == 0
end

puts "[scripts.seed_event_type_for_metrics] Done"