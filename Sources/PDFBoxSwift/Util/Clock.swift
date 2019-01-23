//
//  Clock.swift
//  PDFBoxSwift
//
//  Created by Sergej Jaskiewicz on 23/01/2019.
//

/// The number of seconds since Epoch.
public typealias Timestamp = Double

/// Something that is able to provide the current time and convert it to
/// a calendar representation.
public protocol Clock {

  func now() -> Timestamp

  func calendarTime(fromTimestamp timestamp: Timestamp) -> CalendarTime

  func timestamp(fromCalendarTime time: CalendarTime) -> Timestamp?
}

public struct CalendarTime {

  /// Microseconds after the second.
  public var microseconds: Int

  /// Seconds after the minute — [0, 60].
  public var seconds: Int

  /// Minutes after the hour – [0, 59].
  public var minutes: Int

  /// Hours since midnight – [0, 23].
  public var hours: Int

  /// Day of the month – [1, 31].
  public var day: Int

  /// Months since January – [0, 11].
  public var month: Int

  /// Years since 1900.
  public var year: Int

  /// Days since Sunday – [0, 6].
  public var weekday: Int

  /// Days since January 1 – [0, 365].
  public var dayOfYear: Int

  /// Daylight Saving Time flag.
  public var daylightSaving: DaylightSaving

  /// The time zone offset.
  public var secondsFromGMT: Int

  public var timeZoneAbbreviation: String?

  public init(microseconds: Int,
              seconds: Int,
              minutes: Int,
              hours: Int,
              day: Int,
              month: Int,
              year: Int,
              weekday: Int,
              dayOfYear: Int,
              daylightSaving: DaylightSaving,
              secondsFromGMT: Int,
              timeZoneAbbreviation: String?) {
    self.microseconds = microseconds
    self.seconds = seconds
    self.minutes = minutes
    self.hours = hours
    self.day = day
    self.month = month
    self.year = year
    self.weekday = weekday
    self.dayOfYear = dayOfYear
    self.daylightSaving = daylightSaving
    self.secondsFromGMT = secondsFromGMT
    self.timeZoneAbbreviation = timeZoneAbbreviation
  }
}

/// Daylight Saving Time flag.
public enum DaylightSaving: Int {
  case yes     =  1
  case no      =  0
  case unknown = -1

  public init(rawValue: Int) {
    if rawValue > 0 {
      self = .yes
    } else if rawValue == 0 {
      self = .no
    } else {
      self = .unknown
    }
  }
}
