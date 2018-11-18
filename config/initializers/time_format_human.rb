Time::DATE_FORMATS[:human] = lambda do |date|
  seconds = (Time.zone.now - date).round

  days = seconds / (60 * 60 * 24)
  return "#{days}日前" if days.positive?

  hours = seconds / (60 * 60)
  return "#{hours}時間前" if hours.positive?

  minutes = seconds / 60
  return "#{minutes}分前" if minutes.positive?

  return "#{seconds}秒前"
end
