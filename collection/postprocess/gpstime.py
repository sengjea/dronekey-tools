#!/usr/bin/python
import datetime, time, math, calendar
secs_in_week = 604800
secs_in_day = 86400

gps_epoch_timestamp = calendar.timegm((1980, 1, 6, 0, 0, 0, -1, -1, 0))
leap_seconds = 16 #UTC to GPS timestamp diff

def gps_from_utc(t):
    secFract = t % 1
    tdiff = t - gps_epoch_timestamp
    gps_sow = (tdiff % secs_in_week)
    gps_week = int(math.floor(tdiff/secs_in_week))
    gps_day = int(math.floor(gps_sow/secs_in_day))
    gps_sod = (gps_sow % secs_in_day)
    return (gps_week, gps_sow, gps_day, gps_sod)

def gps_from_string(str_time, str_format, local_time = 0, in_gpstime = 0):
    t = time.strptime(str_time,str_format)
    dt = datetime.datetime.strptime(str_time, str_format)
    return gps_from_utc(calendar.timegm(t)  + dt.microsecond/1e6 + 
                    (leap_seconds if not in_gpstime else 0))

def utc_from_rinex_string(string, is_gpstime = 1):
    time_tuple = tuple([ math.trunc(float(number)) for number in string.split()[0:6]])
    # RINEX String is assuumed to be in GPS time
    # i.e the date-time shown is always leap_seconds ahead of UTC
    # GPS time at 12:00:16 = UTC 12:00:00
    return calendar.timegm(time_tuple + (-1, -1, 0)) + (leap_seconds if is_gpstime else 0)

def utctime_from_gps_sow(string_format, gps_week, gps_sow):
    t = gps_epoch_timestamp + gps_week*secs_in_week + gps_sow - leap_seconds
    return time.strftime(string_format, time.gmtime(t))

if __name__ == "__main__":
    time_fmt = "%Y-%m-%d %H:%M:%S"
    time_str = "2014-08-18 20:21:24"
    true_gw = 1806
    true_gsow = 159700
    print "time_str = {0}".format(time_str)
    print "gps_from_string = {0}".format(gps_from_string(time_str, time_fmt))
    print "true_gw = {0}, true_gsow = {1}".format(true_gw, true_gsow) 
    print "utctime_from_gps_sow = {0}".format(utctime_from_gps_sow(time_fmt, true_gw, true_gsow)) 
    obs_str = "2014     8     7    12    44   43.0000000"
    t = gps_from_utc(utc_from_rinex_string(obs_str, 1))
    print obs_str
    print utctime_from_gps_sow(time_fmt, t[0], t[1])
