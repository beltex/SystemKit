//
// main.swift
// SystemKit
//
// The MIT License
//
// Copyright (C) 2014-2017  beltex <https://github.com/beltex>
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import SystemKit

print("// MACHINE STATUS")

print("\n-- CPU --")
print("\tPHYSICAL CORES:  \(System.physicalCores())")
print("\tLOGICAL CORES:   \(System.logicalCores())")

var sys = System()
let cpuUsage = sys.usageCPU()
print("\tSYSTEM:          \(Int(cpuUsage.system))%")
print("\tUSER:            \(Int(cpuUsage.user))%")
print("\tIDLE:            \(Int(cpuUsage.idle))%")
print("\tNICE:            \(Int(cpuUsage.nice))%")


print("\n-- MEMORY --")
print("\tPHYSICAL SIZE:   \(System.physicalMemory())GB")

let memoryUsage = System.memoryUsage()
func memoryUnit(_ value: Double) -> String {
    if value < 1.0 { return String(Int(value * 1000.0))    + "MB" }
    else           { return NSString(format:"%.2f", value) as String + "GB" }
}

print("\tFREE:            \(memoryUnit(memoryUsage.free))")
print("\tWIRED:           \(memoryUnit(memoryUsage.wired))")
print("\tACTIVE:          \(memoryUnit(memoryUsage.active))")
print("\tINACTIVE:        \(memoryUnit(memoryUsage.inactive))")
print("\tCOMPRESSED:      \(memoryUnit(memoryUsage.compressed))")


print("\n-- SYSTEM --")
print("\tMODEL:           \(System.modelName())")

let names = System.uname()
print("\tSYSNAME:         \(names.sysname)")
print("\tNODENAME:        \(names.nodename)")
print("\tRELEASE:         \(names.release)")
print("\tVERSION:         \(names.version)")
print("\tMACHINE:         \(names.machine)")

let uptime = System.uptime()
print("\tUPTIME:          \(uptime.days)d \(uptime.hrs)h \(uptime.mins)m " +
                            "\(uptime.secs)s")

let counts = System.processCounts()
print("\tPROCESSES:       \(counts.processCount)")
print("\tTHREADS:         \(counts.threadCount)")

let loadAverage = System.loadAverage().map { NSString(format:"%.2f", $0) }
print("\tLOAD AVERAGE:    \(loadAverage)")
print("\tMACH FACTOR:     \(System.machFactor())")


print("\n-- POWER --")
let cpuThermalStatus = System.CPUPowerLimit()

print("\tCPU SPEED LIMIT: \(cpuThermalStatus.processorSpeed)%")
print("\tCPUs AVAILABLE:  \(cpuThermalStatus.processorCount)")
print("\tSCHEDULER LIMIT: \(cpuThermalStatus.schedulerTime)%")

print("\tTHERMAL LEVEL:   \(System.thermalLevel().rawValue)")

var battery = Battery()
if battery.open() != kIOReturnSuccess { exit(0) }

print("\n-- BATTERY --")
print("\tAC POWERED:      \(battery.isACPowered())")
print("\tCHARGED:         \(battery.isCharged())")
print("\tCHARGING:        \(battery.isCharging())")
print("\tCHARGE:          \(battery.charge())%")
print("\tCAPACITY:        \(battery.currentCapacity()) mAh")
print("\tMAX CAPACITY:    \(battery.maxCapactiy()) mAh")
print("\tDESGIN CAPACITY: \(battery.designCapacity()) mAh")
print("\tCYCLES:          \(battery.cycleCount())")
print("\tMAX CYCLES:      \(battery.designCycleCount())")
print("\tTEMPERATURE:     \(battery.temperature())°C")
print("\tTIME REMAINING:  \(battery.timeRemainingFormatted())")

_ = battery.close()
