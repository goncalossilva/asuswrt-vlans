# Asuswrt VLANS

Example VLAN setup across a router, an ASUS RT-AC68U (AP mode) and an ASUS RT-AC66U (AP mode):

```
+--------+        +----------+        +----------+
| Router |--------| RT-AC68U |--------| RT-AC66U |
+--------+        +----------+        +----------+
```

All 3 of them having clients on different ethernet ports tagged with different VLANs, and both APs having multiple wireless networks each tagged with a different VLAN. More information in the code itself.

For this to work reliably, hardware accelaration must be disabled in both access points:

```
nvram set ctf_disable=1
nvram set ctf_disable_force=1
nvram commit
```
