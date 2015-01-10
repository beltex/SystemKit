SystemKit
=========

An OS X system library in Swift based off of
[libtop](http://www.opensource.apple.com/source/top/top-100.1.2/libtop.c), from
Apple's top implementation.

For an example usage of this library, see
[dshb](https://github.com/beltex/dshb), an OS X system monitor in Swift. Also,
for OS X folks, for more system related statistics, see
[SMCKit](https://github.com/beltex/SMCKit), an Apple SMC library in Swift.


### Example

Sample ouput from
[example](https://github.com/beltex/SystemKit/blob/master/Example/main.swift).

```
// MACHINE STATUS

-- CPU --
  PHYSICAL CORES:  2
  LOGICAL CORES:   2
  SYSTEM:          10%
  USER:            17%
  IDLE:            71%
  NICE:            0%

-- MEMORY --
  PHYSICAL SIZE:   7.75GB
  FREE:            1.33GB
  WIRED:           866MB
  ACTIVE:          5.04GB
  INACTIVE:        516MB
  COMPRESSED:      0MB

-- SYSTEM --
  PROCESSES:       197
  THREADS:         967
  LOAD AVERAGE:    [3.18, 3.89, 3.99]
  MACH FACTOR:     (0.436, 0.385, 0.322)

-- BATTERY --
  AC POWERED:      true
  CHARGED:         true
  CHARGING:        false
  CHARGE:          100.0%
  CAPACITY:        1675 mAh
  MAX CAPACITY:    1675 mAh
  DESGIN CAPACITY: 5450 mAh
  CYCLES:          646
  MAX CYCLES:      1000
  TEMPERATURE:     30.0°C
```

### References

- [top](http://www.opensource.apple.com/source/top/)
- [hostinfo](http://www.opensource.apple.com/source/system_cmds/)
- [vm_stat](http://www.opensource.apple.com/source/system_cmds/)
- iStat Pro


### License

This project is under the **MIT License**.
