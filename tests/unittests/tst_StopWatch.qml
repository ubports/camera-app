import QtQuick 2.0
import QtTest 1.0
import "../../"

TestCase {
    name: "StopWatch"

    function test_time_format_calc() {
        stopWatch.time = 1234
        compare(stopWatch.elapsed, "20:34", "Time not calculated correctly")
    }

    function test_time_format_pad() {
        stopWatch.time = 5
        compare(stopWatch.elapsed, "00:05", "Time not calculated correctly")
    }

    StopWatch {
        id: stopWatch
    }
}
