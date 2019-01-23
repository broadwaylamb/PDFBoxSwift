//
//  POSIXClock.swift
//  PDFBoxSwift
//
//  Created by Sergej Jaskiewicz on 23/01/2019.
//

#if canImport(Darwin)
import Darwin
#elseif canImport(Glibc)
import Glibc
#endif

#if canImport(Darwin) || canImport(Glibc)

public struct POSIXClock: Clock {

  public static let `default` = POSIXClock()

  private init() {}

  public func now() -> Timestamp {
    var timestamp = timeval()
    gettimeofday(&timestamp, nil)
    return Timestamp(timestamp.tv_sec) + Timestamp(timestamp.tv_usec) / 1000000
  }

  public func calendarTime(fromTimestamp timestamp: Timestamp) -> CalendarTime {

    var tvSec = time_t(timestamp)
    var calTime = tm()

    localtime_r(&tvSec, &calTime)

    return CalendarTime(
      microseconds: Int(timestamp.truncatingRemainder(dividingBy: 1) * 1000000),
      seconds: Int(calTime.tm_sec),
      minutes: Int(calTime.tm_min),
      hours: Int(calTime.tm_hour),
      day: Int(calTime.tm_mday),
      month: Int(calTime.tm_mon),
      year: Int(calTime.tm_year),
      weekday: Int(calTime.tm_wday),
      dayOfYear: Int(calTime.tm_yday),
      daylightSaving: DaylightSaving(rawValue: Int(calTime.tm_isdst)),
      secondsFromGMT: calTime.tm_gmtoff,
      timeZoneAbbreviation: String(cString: calTime.tm_zone)
    )
  }

  public func timestamp(fromCalendarTime time: CalendarTime) -> Timestamp? {
    var calTime = tm(tm_sec: CInt(time.seconds),
                     tm_min: CInt(time.minutes),
                     tm_hour: CInt(time.hours),
                     tm_mday: CInt(time.day),
                     tm_mon: CInt(time.month),
                     tm_year: CInt(time.year),
                     tm_wday: CInt(time.weekday),
                     tm_yday: CInt(time.dayOfYear),
                     tm_isdst: CInt(time.daylightSaving.rawValue),
                     tm_gmtoff: time.secondsFromGMT,
                     tm_zone: nil)

    let timestamp = mktime(&calTime)

    if timestamp == -1 && errno == EOVERFLOW {
      return nil
    }

    return Timestamp(timestamp) + Timestamp(time.microseconds) / 1000000
  }
}

#endif
