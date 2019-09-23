# Resource-Categorization


>Resource-Categorization - Resource Management
>CRAAX - UPC, 2019
>The Resource-Categorization module is a component of the European Project mF2C.

Resource-Categorization module is responsible for:
- Categorizing the participating devices in the mF2C system
- Continuous monitoring of the resource capacity
- In the Leader side, it is responsible for providing the aggregated Fog Area resource information 

## Usage

The Resource-Categorization module can be run ussing the dockerized version or directly from source.

The Policies module can be run ussing the dockerized version or directly from source.

#### Docker

Last build version from docker hub: `docker run --rm mf2c/resource-categorization:<version>`

Replace *<version>* with a valid uploaded version [here](https://cloud.docker.com/u/mf2c/repository/docker/mf2c/resource-categorization/tags).

#### Source

`Python 3.x` is required to execute this code.

1. Clone the repository with Git. It's hightly recomended to create a Python virtual environment.
2. Install all the library dependencies: `pip3 install -r requirements.txt`
3. Install the hwloc package: `sudo apt-get install hwloc`
4. Execute the following command: `python3 main.py`

 

### API

All the API calls are made via REST. The endpoints and required parameters can be consulted on [http://{categorization_address}:46070/](http://localhost:46050/)

**Note:** Replace *categorization_address* with the real address of the container or device where the code is running.


#### Resource-Categorization Status


- **GET**  device-static information - (**For `latest-V2.0.17`)

```bash
curl -X GET "http://localhost/api/device" -H "accept: application/json"
```

- **RESPONSES**
    - **200** - Success
    - **Response Payload:** 

 ```
{
   "count": 1,
   "acl": {
      "owner": {
         "principal": "ADMIN",
         "type": "ROLE"
      },
      "rules": [
         {
            "principal": "USER",
            "type": "ROLE",
            "right": "MODIFY"
         }
      ]
   },
   "resourceURI": "http://schemas.dmtf.org/cimi/2/DeviceCollection",
   "id": "device",
   "operations": [
      {
         "rel": "add",
         "href": "device"
      }
   ],
   "devices": [
      {
         "updated": "2019-05-22T10:10:06.569Z",
         "cpuinfo": "processor\t: 0\nvendor_id\t: GenuineIntel\ncpu family\t: 6\nmodel\t\t: 158\nmodel name\t: Intel(R) Core(TM) i7-7700 CPU @ 3.60GHz\nstepping\t: 9\nmicrocode\t: 0xb4\ncpu MHz\t\t: 3821.606\ncache size\t: 8192 KB\nphysical id\t: 0\nsiblings\t: 8\ncore id\t\t: 0\ncpu cores\t: 4\napicid\t\t: 0\ninitial apicid\t: 0\nfpu\t\t: yes\nfpu_exception\t: yes\ncpuid level\t: 22\nwp\t\t: yes\nflags\t\t: fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe syscall nx pdpe1gb rdtscp lm constant_tsc art arch_perfmon pebs bts rep_good nopl xtopology nonstop_tsc cpuid aperfmperf tsc_known_freq pni pclmulqdq dtes64 monitor ds_cpl vmx smx est tm2 ssse3 sdbg fma cx16 xtpr pdcm pcid sse4_1 sse4_2 x2apic movbe popcnt tsc_deadline_timer aes xsave avx f16c rdrand lahf_lm abm 3dnowprefetch cpuid_fault invpcid_single pti ssbd ibrs ibpb stibp tpr_shadow vnmi flexpriority ept vpid fsgsbase tsc_adjust bmi1 hle avx2 smep bmi2 erms invpcid rtm mpx rdseed adx smap clflushopt intel_pt xsaveopt xsavec xgetbv1 xsaves dtherm ida arat pln pts hwp hwp_notify hwp_act_window hwp_epp flush_l1d\nbugs\t\t: cpu_meltdown spectre_v1 spectre_v2 spec_store_bypass l1tf\nbogomips\t: 7200.00\nclflush size\t: 64\ncache_alignment\t: 64\naddress sizes\t: 39 bits physical, 48 bits virtual\npower management:\n\nprocessor\t: 1\nvendor_id\t: GenuineIntel\ncpu family\t: 6\nmodel\t\t: 158\nmodel name\t: Intel(R) Core(TM) i7-7700 CPU @ 3.60GHz\nstepping\t: 9\nmicrocode\t: 0xb4\ncpu MHz\t\t: 3823.348\ncache size\t: 8192 KB\nphysical id\t: 0\nsiblings\t: 8\ncore id\t\t: 1\ncpu cores\t: 4\napicid\t\t: 2\ninitial apicid\t: 2\nfpu\t\t: yes\nfpu_exception\t: yes\ncpuid level\t: 22\nwp\t\t: yes\nflags\t\t: fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe syscall nx pdpe1gb rdtscp lm constant_tsc art arch_perfmon pebs bts rep_good nopl xtopology nonstop_tsc cpuid aperfmperf tsc_known_freq pni pclmulqdq dtes64 monitor ds_cpl vmx smx est tm2 ssse3 sdbg fma cx16 xtpr pdcm pcid sse4_1 sse4_2 x2apic movbe popcnt tsc_deadline_timer aes xsave avx f16c rdrand lahf_lm abm 3dnowprefetch cpuid_fault invpcid_single pti ssbd ibrs ibpb stibp tpr_shadow vnmi flexpriority ept vpid fsgsbase tsc_adjust bmi1 hle avx2 smep bmi2 erms invpcid rtm mpx rdseed adx smap clflushopt intel_pt xsaveopt xsavec xgetbv1 xsaves dtherm ida arat pln pts hwp hwp_notify hwp_act_window hwp_epp flush_l1d\nbugs\t\t: cpu_meltdown spectre_v1 spectre_v2 spec_store_bypass l1tf\nbogomips\t: 7200.00\nclflush size\t: 64\ncache_alignment\t: 64\naddress sizes\t: 39 bits physical, 48 bits virtual\npower management:\n\nprocessor\t: 2\nvendor_id\t: GenuineIntel\ncpu family\t: 6\nmodel\t\t: 158\nmodel name\t: Intel(R) Core(TM) i7-7700 CPU @ 3.60GHz\nstepping\t: 9\nmicrocode\t: 0xb4\ncpu MHz\t\t: 3823.727\ncache size\t: 8192 KB\nphysical id\t: 0\nsiblings\t: 8\ncore id\t\t: 2\ncpu cores\t: 4\napicid\t\t: 4\ninitial apicid\t: 4\nfpu\t\t: yes\nfpu_exception\t: yes\ncpuid level\t: 22\nwp\t\t: yes\nflags\t\t: fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe syscall nx pdpe1gb rdtscp lm constant_tsc art arch_perfmon pebs bts rep_good nopl xtopology nonstop_tsc cpuid aperfmperf tsc_known_freq pni pclmulqdq dtes64 monitor ds_cpl vmx smx est tm2 ssse3 sdbg fma cx16 xtpr pdcm pcid sse4_1 sse4_2 x2apic movbe popcnt tsc_deadline_timer aes xsave avx f16c rdrand lahf_lm abm 3dnowprefetch cpuid_fault invpcid_single pti ssbd ibrs ibpb stibp tpr_shadow vnmi flexpriority ept vpid fsgsbase tsc_adjust bmi1 hle avx2 smep bmi2 erms invpcid rtm mpx rdseed adx smap clflushopt intel_pt xsaveopt xsavec xgetbv1 xsaves dtherm ida arat pln pts hwp hwp_notify hwp_act_window hwp_epp flush_l1d\nbugs\t\t: cpu_meltdown spectre_v1 spectre_v2 spec_store_bypass l1tf\nbogomips\t: 7200.00\nclflush size\t: 64\ncache_alignment\t: 64\naddress sizes\t: 39 bits physical, 48 bits virtual\npower management:\n\nprocessor\t: 3\nvendor_id\t: GenuineIntel\ncpu family\t: 6\nmodel\t\t: 158\nmodel name\t: Intel(R) Core(TM) i7-7700 CPU @ 3.60GHz\nstepping\t: 9\nmicrocode\t: 0xb4\ncpu MHz\t\t: 3822.621\ncache size\t: 8192 KB\nphysical id\t: 0\nsiblings\t: 8\ncore id\t\t: 3\ncpu cores\t: 4\napicid\t\t: 6\ninitial apicid\t: 6\nfpu\t\t: yes\nfpu_exception\t: yes\ncpuid level\t: 22\nwp\t\t: yes\nflags\t\t: fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe syscall nx pdpe1gb rdtscp lm constant_tsc art arch_perfmon pebs bts rep_good nopl xtopology nonstop_tsc cpuid aperfmperf tsc_known_freq pni pclmulqdq dtes64 monitor ds_cpl vmx smx est tm2 ssse3 sdbg fma cx16 xtpr pdcm pcid sse4_1 sse4_2 x2apic movbe popcnt tsc_deadline_timer aes xsave avx f16c rdrand lahf_lm abm 3dnowprefetch cpuid_fault invpcid_single pti ssbd ibrs ibpb stibp tpr_shadow vnmi flexpriority ept vpid fsgsbase tsc_adjust bmi1 hle avx2 smep bmi2 erms invpcid rtm mpx rdseed adx smap clflushopt intel_pt xsaveopt xsavec xgetbv1 xsaves dtherm ida arat pln pts hwp hwp_notify hwp_act_window hwp_epp flush_l1d\nbugs\t\t: cpu_meltdown spectre_v1 spectre_v2 spec_store_bypass l1tf\nbogomips\t: 7200.00\nclflush size\t: 64\ncache_alignment\t: 64\naddress sizes\t: 39 bits physical, 48 bits virtual\npower management:\n\nprocessor\t: 4\nvendor_id\t: GenuineIntel\ncpu family\t: 6\nmodel\t\t: 158\nmodel name\t: Intel(R) Core(TM) i7-7700 CPU @ 3.60GHz\nstepping\t: 9\nmicrocode\t: 0xb4\ncpu MHz\t\t: 3822.299\ncache size\t: 8192 KB\nphysical id\t: 0\nsiblings\t: 8\ncore id\t\t: 0\ncpu cores\t: 4\napicid\t\t: 1\ninitial apicid\t: 1\nfpu\t\t: yes\nfpu_exception\t: yes\ncpuid level\t: 22\nwp\t\t: yes\nflags\t\t: fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe syscall nx pdpe1gb rdtscp lm constant_tsc art arch_perfmon pebs bts rep_good nopl xtopology nonstop_tsc cpuid aperfmperf tsc_known_freq pni pclmulqdq dtes64 monitor ds_cpl vmx smx est tm2 ssse3 sdbg fma cx16 xtpr pdcm pcid sse4_1 sse4_2 x2apic movbe popcnt tsc_deadline_timer aes xsave avx f16c rdrand lahf_lm abm 3dnowprefetch cpuid_fault invpcid_single pti ssbd ibrs ibpb stibp tpr_shadow vnmi flexpriority ept vpid fsgsbase tsc_adjust bmi1 hle avx2 smep bmi2 erms invpcid rtm mpx rdseed adx smap clflushopt intel_pt xsaveopt xsavec xgetbv1 xsaves dtherm ida arat pln pts hwp hwp_notify hwp_act_window hwp_epp flush_l1d\nbugs\t\t: cpu_meltdown spectre_v1 spectre_v2 spec_store_bypass l1tf\nbogomips\t: 7200.00\nclflush size\t: 64\ncache_alignment\t: 64\naddress sizes\t: 39 bits physical, 48 bits virtual\npower management:\n\nprocessor\t: 5\nvendor_id\t: GenuineIntel\ncpu family\t: 6\nmodel\t\t: 158\nmodel name\t: Intel(R) Core(TM) i7-7700 CPU @ 3.60GHz\nstepping\t: 9\nmicrocode\t: 0xb4\ncpu MHz\t\t: 3822.359\ncache size\t: 8192 KB\nphysical id\t: 0\nsiblings\t: 8\ncore id\t\t: 1\ncpu cores\t: 4\napicid\t\t: 3\ninitial apicid\t: 3\nfpu\t\t: yes\nfpu_exception\t: yes\ncpuid level\t: 22\nwp\t\t: yes\nflags\t\t: fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe syscall nx pdpe1gb rdtscp lm constant_tsc art arch_perfmon pebs bts rep_good nopl xtopology nonstop_tsc cpuid aperfmperf tsc_known_freq pni pclmulqdq dtes64 monitor ds_cpl vmx smx est tm2 ssse3 sdbg fma cx16 xtpr pdcm pcid sse4_1 sse4_2 x2apic movbe popcnt tsc_deadline_timer aes xsave avx f16c rdrand lahf_lm abm 3dnowprefetch cpuid_fault invpcid_single pti ssbd ibrs ibpb stibp tpr_shadow vnmi flexpriority ept vpid fsgsbase tsc_adjust bmi1 hle avx2 smep bmi2 erms invpcid rtm mpx rdseed adx smap clflushopt intel_pt xsaveopt xsavec xgetbv1 xsaves dtherm ida arat pln pts hwp hwp_notify hwp_act_window hwp_epp flush_l1d\nbugs\t\t: cpu_meltdown spectre_v1 spectre_v2 spec_store_bypass l1tf\nbogomips\t: 7200.00\nclflush size\t: 64\ncache_alignment\t: 64\naddress sizes\t: 39 bits physical, 48 bits virtual\npower management:\n\nprocessor\t: 6\nvendor_id\t: GenuineIntel\ncpu family\t: 6\nmodel\t\t: 158\nmodel name\t: Intel(R) Core(TM) i7-7700 CPU @ 3.60GHz\nstepping\t: 9\nmicrocode\t: 0xb4\ncpu MHz\t\t: 3820.759\ncache size\t: 8192 KB\nphysical id\t: 0\nsiblings\t: 8\ncore id\t\t: 2\ncpu cores\t: 4\napicid\t\t: 5\ninitial apicid\t: 5\nfpu\t\t: yes\nfpu_exception\t: yes\ncpuid level\t: 22\nwp\t\t: yes\nflags\t\t: fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe syscall nx pdpe1gb rdtscp lm constant_tsc art arch_perfmon pebs bts rep_good nopl xtopology nonstop_tsc cpuid aperfmperf tsc_known_freq pni pclmulqdq dtes64 monitor ds_cpl vmx smx est tm2 ssse3 sdbg fma cx16 xtpr pdcm pcid sse4_1 sse4_2 x2apic movbe popcnt tsc_deadline_timer aes xsave avx f16c rdrand lahf_lm abm 3dnowprefetch cpuid_fault invpcid_single pti ssbd ibrs ibpb stibp tpr_shadow vnmi flexpriority ept vpid fsgsbase tsc_adjust bmi1 hle avx2 smep bmi2 erms invpcid rtm mpx rdseed adx smap clflushopt intel_pt xsaveopt xsavec xgetbv1 xsaves dtherm ida arat pln pts hwp hwp_notify hwp_act_window hwp_epp flush_l1d\nbugs\t\t: cpu_meltdown spectre_v1 spectre_v2 spec_store_bypass l1tf\nbogomips\t: 7200.00\nclflush size\t: 64\ncache_alignment\t: 64\naddress sizes\t: 39 bits physical, 48 bits virtual\npower management:\n\nprocessor\t: 7\nvendor_id\t: GenuineIntel\ncpu family\t: 6\nmodel\t\t: 158\nmodel name\t: Intel(R) Core(TM) i7-7700 CPU @ 3.60GHz\nstepping\t: 9\nmicrocode\t: 0xb4\ncpu MHz\t\t: 3823.942\ncache size\t: 8192 KB\nphysical id\t: 0\nsiblings\t: 8\ncore id\t\t: 3\ncpu cores\t: 4\napicid\t\t: 7\ninitial apicid\t: 7\nfpu\t\t: yes\nfpu_exception\t: yes\ncpuid level\t: 22\nwp\t\t: yes\nflags\t\t: fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe syscall nx pdpe1gb rdtscp lm constant_tsc art arch_perfmon pebs bts rep_good nopl xtopology nonstop_tsc cpuid aperfmperf tsc_known_freq pni pclmulqdq dtes64 monitor ds_cpl vmx smx est tm2 ssse3 sdbg fma cx16 xtpr pdcm pcid sse4_1 sse4_2 x2apic movbe popcnt tsc_deadline_timer aes xsave avx f16c rdrand lahf_lm abm 3dnowprefetch cpuid_fault invpcid_single pti ssbd ibrs ibpb stibp tpr_shadow vnmi flexpriority ept vpid fsgsbase tsc_adjust bmi1 hle avx2 smep bmi2 erms invpcid rtm mpx rdseed adx smap clflushopt intel_pt xsaveopt xsavec xgetbv1 xsaves dtherm ida arat pln pts hwp hwp_notify hwp_act_window hwp_epp flush_l1d\nbugs\t\t: cpu_meltdown spectre_v1 spectre_v2 spec_store_bypass l1tf\nbogomips\t: 7200.00\nclflush size\t: 64\ncache_alignment\t: 64\naddress sizes\t: 39 bits physical, 48 bits virtual\npower management:\n\n",
         "memory": 32127.988,
         "logicalCores": 8,
         "cpuManufacturer": "Intel(R) Core(TM) i7-7700 CPU @ 3.60GHz",
         "arch": "x86_64",
         "physicalCores": 4,
         "created": "2019-05-22T10:10:06.569Z",
         "networkingStandards": "enp0s31f6",
         "id": "device/7af201c2-f7fe-410d-92bd-c18eca9444ff",
         "isLeader": false,
         "deviceID": "438f508ee530a9694542441757faf40e991276c4fb59ba93bd1f51a265cf9b49e4d9c97793e141df7a04df388ef3a7a6d97b3a33133e860423634bbf4af604b4",
         "acl": {
            "owner": {
               "principal": "ADMIN",
               "type": "ROLE"
            }
         },
         "operations": [
            {
               "rel": "edit",
               "href": "device/7af201c2-f7fe-410d-92bd-c18eca9444ff"
            },
            {
               "rel": "delete",
               "href": "device/7af201c2-f7fe-410d-92bd-c18eca9444ff"
            }
         ],
         "storage": 480584,
         "hwloc": "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<!DOCTYPE topology SYSTEM \"hwloc.dtd\">\n<topology>\n  <object type=\"Machine\" os_index=\"0\" cpuset=\"0x000000ff\" complete_cpuset=\"0x000000ff\" online_cpuset=\"0x000000ff\" allowed_cpuset=\"0x000000ff\" local_memory=\"33688637440\">\n    <page_type size=\"4096\" count=\"8224765\"/>\n    <page_type size=\"2097152\" count=\"0\"/>\n    <page_type size=\"1073741824\" count=\"0\"/>\n    <info name=\"DMIProductName\" value=\"MS-7A72\"/>\n    <info name=\"DMIProductVersion\" value=\"1.0\"/>\n    <info name=\"DMIProductSerial\" value=\"Default string\"/>\n    <info name=\"DMIProductUUID\" value=\"00000000-0000-0000-0000-4CCC6AF5A3EA\"/>\n    <info name=\"DMIBoardVendor\" value=\"MSI\"/>\n    <info name=\"DMIBoardName\" value=\"H270 PC MATE (MS-7A72)\"/>\n    <info name=\"DMIBoardVersion\" value=\"1.0\"/>\n    <info name=\"DMIBoardSerial\" value=\"H216677116\"/>\n    <info name=\"DMIBoardAssetTag\" value=\"Default string\"/>\n    <info name=\"DMIChassisVendor\" value=\"MSI\"/>\n    <info name=\"DMIChassisType\" value=\"3\"/>\n    <info name=\"DMIChassisVersion\" value=\"1.0\"/>\n    <info name=\"DMIChassisSerial\" value=\"Default string\"/>\n    <info name=\"DMIChassisAssetTag\" value=\"Default string\"/>\n    <info name=\"DMIBIOSVendor\" value=\"American Megatrends Inc.\"/>\n    <info name=\"DMIBIOSVersion\" value=\"2.60\"/>\n    <info name=\"DMIBIOSDate\" value=\"11/16/2017\"/>\n    <info name=\"DMISysVendor\" value=\"MSI\"/>\n    <info name=\"Backend\" value=\"Linux\"/>\n    <info name=\"LinuxCgroup\" value=\"/docker/a2e4cf59961bc6980d0057d8322a019c3e7923843583602a4cb7b3f039b58f14\"/>\n    <info name=\"OSName\" value=\"Linux\"/>\n    <info name=\"OSRelease\" value=\"4.15.0-48-generic\"/>\n    <info name=\"OSVersion\" value=\"#51~16.04.1-Ubuntu SMP Fri Apr 5 12:01:12 UTC 2019\"/>\n    <info name=\"HostName\" value=\"a2e4cf59961b\"/>\n    <info name=\"Architecture\" value=\"x86_64\"/>\n    <info name=\"hwlocVersion\" value=\"1.11.5\"/>\n    <info name=\"ProcessName\" value=\"hwloc-ls\"/>\n    <object type=\"Package\" os_index=\"0\" cpuset=\"0x000000ff\" complete_cpuset=\"0x000000ff\" online_cpuset=\"0x000000ff\" allowed_cpuset=\"0x000000ff\">\n      <info name=\"CPUVendor\" value=\"GenuineIntel\"/>\n      <info name=\"CPUFamilyNumber\" value=\"6\"/>\n      <info name=\"CPUModelNumber\" value=\"158\"/>\n      <info name=\"CPUModel\" value=\"Intel(R) Core(TM) i7-7700 CPU @ 3.60GHz\"/>\n      <info name=\"CPUStepping\" value=\"9\"/>\n      <object type=\"Cache\" cpuset=\"0x000000ff\" complete_cpuset=\"0x000000ff\" online_cpuset=\"0x000000ff\" allowed_cpuset=\"0x000000ff\" cache_size=\"8388608\" depth=\"3\" cache_linesize=\"64\" cache_associativity=\"16\" cache_type=\"0\">\n        <info name=\"Inclusive\" value=\"1\"/>\n        <object type=\"Cache\" cpuset=\"0x00000011\" complete_cpuset=\"0x00000011\" online_cpuset=\"0x00000011\" allowed_cpuset=\"0x00000011\" cache_size=\"262144\" depth=\"2\" cache_linesize=\"64\" cache_associativity=\"4\" cache_type=\"0\">\n          <info name=\"Inclusive\" value=\"0\"/>\n          <object type=\"Cache\" cpuset=\"0x00000011\" complete_cpuset=\"0x00000011\" online_cpuset=\"0x00000011\" allowed_cpuset=\"0x00000011\" cache_size=\"32768\" depth=\"1\" cache_linesize=\"64\" cache_associativity=\"8\" cache_type=\"1\">\n            <info name=\"Inclusive\" value=\"0\"/>\n            <object type=\"Cache\" cpuset=\"0x00000011\" complete_cpuset=\"0x00000011\" online_cpuset=\"0x00000011\" allowed_cpuset=\"0x00000011\" cache_size=\"32768\" depth=\"1\" cache_linesize=\"64\" cache_associativity=\"8\" cache_type=\"2\">\n              <info name=\"Inclusive\" value=\"0\"/>\n              <object type=\"Core\" os_index=\"0\" cpuset=\"0x00000011\" complete_cpuset=\"0x00000011\" online_cpuset=\"0x00000011\" allowed_cpuset=\"0x00000011\">\n                <object type=\"PU\" os_index=\"0\" cpuset=\"0x00000001\" complete_cpuset=\"0x00000001\" online_cpuset=\"0x00000001\" allowed_cpuset=\"0x00000001\"/>\n                <object type=\"PU\" os_index=\"4\" cpuset=\"0x00000010\" complete_cpuset=\"0x00000010\" online_cpuset=\"0x00000010\" allowed_cpuset=\"0x00000010\"/>\n              <\/object>\n            <\/object>\n          <\/object>\n        <\/object>\n        <object type=\"Cache\" cpuset=\"0x00000022\" complete_cpuset=\"0x00000022\" online_cpuset=\"0x00000022\" allowed_cpuset=\"0x00000022\" cache_size=\"262144\" depth=\"2\" cache_linesize=\"64\" cache_associativity=\"4\" cache_type=\"0\">\n          <info name=\"Inclusive\" value=\"0\"/>\n          <object type=\"Cache\" cpuset=\"0x00000022\" complete_cpuset=\"0x00000022\" online_cpuset=\"0x00000022\" allowed_cpuset=\"0x00000022\" cache_size=\"32768\" depth=\"1\" cache_linesize=\"64\" cache_associativity=\"8\" cache_type=\"1\">\n            <info name=\"Inclusive\" value=\"0\"/>\n            <object type=\"Cache\" cpuset=\"0x00000022\" complete_cpuset=\"0x00000022\" online_cpuset=\"0x00000022\" allowed_cpuset=\"0x00000022\" cache_size=\"32768\" depth=\"1\" cache_linesize=\"64\" cache_associativity=\"8\" cache_type=\"2\">\n              <info name=\"Inclusive\" value=\"0\"/>\n              <object type=\"Core\" os_index=\"1\" cpuset=\"0x00000022\" complete_cpuset=\"0x00000022\" online_cpuset=\"0x00000022\" allowed_cpuset=\"0x00000022\">\n                <object type=\"PU\" os_index=\"1\" cpuset=\"0x00000002\" complete_cpuset=\"0x00000002\" online_cpuset=\"0x00000002\" allowed_cpuset=\"0x00000002\"/>\n                <object type=\"PU\" os_index=\"5\" cpuset=\"0x00000020\" complete_cpuset=\"0x00000020\" online_cpuset=\"0x00000020\" allowed_cpuset=\"0x00000020\"/>\n              <\/object>\n            <\/object>\n          <\/object>\n        <\/object>\n        <object type=\"Cache\" cpuset=\"0x00000044\" complete_cpuset=\"0x00000044\" online_cpuset=\"0x00000044\" allowed_cpuset=\"0x00000044\" cache_size=\"262144\" depth=\"2\" cache_linesize=\"64\" cache_associativity=\"4\" cache_type=\"0\">\n          <info name=\"Inclusive\" value=\"0\"/>\n          <object type=\"Cache\" cpuset=\"0x00000044\" complete_cpuset=\"0x00000044\" online_cpuset=\"0x00000044\" allowed_cpuset=\"0x00000044\" cache_size=\"32768\" depth=\"1\" cache_linesize=\"64\" cache_associativity=\"8\" cache_type=\"1\">\n            <info name=\"Inclusive\" value=\"0\"/>\n            <object type=\"Cache\" cpuset=\"0x00000044\" complete_cpuset=\"0x00000044\" online_cpuset=\"0x00000044\" allowed_cpuset=\"0x00000044\" cache_size=\"32768\" depth=\"1\" cache_linesize=\"64\" cache_associativity=\"8\" cache_type=\"2\">\n              <info name=\"Inclusive\" value=\"0\"/>\n              <object type=\"Core\" os_index=\"2\" cpuset=\"0x00000044\" complete_cpuset=\"0x00000044\" online_cpuset=\"0x00000044\" allowed_cpuset=\"0x00000044\">\n                <object type=\"PU\" os_index=\"2\" cpuset=\"0x00000004\" complete_cpuset=\"0x00000004\" online_cpuset=\"0x00000004\" allowed_cpuset=\"0x00000004\"/>\n                <object type=\"PU\" os_index=\"6\" cpuset=\"0x00000040\" complete_cpuset=\"0x00000040\" online_cpuset=\"0x00000040\" allowed_cpuset=\"0x00000040\"/>\n              <\/object>\n            <\/object>\n          <\/object>\n        <\/object>\n        <object type=\"Cache\" cpuset=\"0x00000088\" complete_cpuset=\"0x00000088\" online_cpuset=\"0x00000088\" allowed_cpuset=\"0x00000088\" cache_size=\"262144\" depth=\"2\" cache_linesize=\"64\" cache_associativity=\"4\" cache_type=\"0\">\n          <info name=\"Inclusive\" value=\"0\"/>\n          <object type=\"Cache\" cpuset=\"0x00000088\" complete_cpuset=\"0x00000088\" online_cpuset=\"0x00000088\" allowed_cpuset=\"0x00000088\" cache_size=\"32768\" depth=\"1\" cache_linesize=\"64\" cache_associativity=\"8\" cache_type=\"1\">\n            <info name=\"Inclusive\" value=\"0\"/>\n            <object type=\"Cache\" cpuset=\"0x00000088\" complete_cpuset=\"0x00000088\" online_cpuset=\"0x00000088\" allowed_cpuset=\"0x00000088\" cache_size=\"32768\" depth=\"1\" cache_linesize=\"64\" cache_associativity=\"8\" cache_type=\"2\">\n              <info name=\"Inclusive\" value=\"0\"/>\n              <object type=\"Core\" os_index=\"3\" cpuset=\"0x00000088\" complete_cpuset=\"0x00000088\" online_cpuset=\"0x00000088\" allowed_cpuset=\"0x00000088\">\n                <object type=\"PU\" os_index=\"3\" cpuset=\"0x00000008\" complete_cpuset=\"0x00000008\" online_cpuset=\"0x00000008\" allowed_cpuset=\"0x00000008\"/>\n                <object type=\"PU\" os_index=\"7\" cpuset=\"0x00000080\" complete_cpuset=\"0x00000080\" online_cpuset=\"0x00000080\" allowed_cpuset=\"0x00000080\"/>\n              <\/object>\n            <\/object>\n          <\/object>\n        <\/object>\n      <\/object>\n    <\/object>\n    <object type=\"Bridge\" os_index=\"0\" bridge_type=\"0-1\" depth=\"0\" bridge_pci=\"0000:[00-04]\">\n      <object type=\"Bridge\" os_index=\"16\" bridge_type=\"1-1\" depth=\"1\" bridge_pci=\"0000:[01-01]\" pci_busid=\"0000:00:01.0\" pci_type=\"0604 [8086:1901] [1462:7a72] 05\" pci_link_speed=\"4.000000\">\n        <object type=\"PCIDev\" os_index=\"4096\" pci_busid=\"0000:01:00.0\" pci_type=\"0300 [10de:1287] [1458:3666] a1\" pci_link_speed=\"4.000000\">\n          <object type=\"OSDev\" name=\"renderD128\" osdev_type=\"1\"/>\n          <object type=\"OSDev\" name=\"controlD64\" osdev_type=\"1\"/>\n          <object type=\"OSDev\" name=\"card0\" osdev_type=\"1\"/>\n        <\/object>\n      <\/object>\n      <object type=\"PCIDev\" os_index=\"368\" pci_busid=\"0000:00:17.0\" pci_type=\"0106 [8086:a282] [1462:7a72] 00\" pci_link_speed=\"0.000000\">\n        <object type=\"OSDev\" name=\"sda\" osdev_type=\"0\">\n          <info name=\"LinuxDeviceID\" value=\"8:0\"/>\n        <\/object>\n        <object type=\"OSDev\" name=\"sr0\" osdev_type=\"0\">\n          <info name=\"LinuxDeviceID\" value=\"11:0\"/>\n        <\/object>\n      <\/object>\n      <object type=\"PCIDev\" os_index=\"502\" pci_busid=\"0000:00:1f.6\" pci_type=\"0200 [8086:15b8] [1462:7a72] 00\" pci_link_speed=\"0.000000\"/>\n    <\/object>\n  <\/object>\n<\/topology>\n",
         "resourceURI": "http://schemas.dmtf.org/cimi/2/Device",
         "os": "Linux-4.15.0-48-generic-x86_64-with-debian-9.9",
         "cpuClockSpeed": "3.6000 GHz",
         "agentType": "Fog Agent"
      }
   ]
}
```

- **POST**  device-static information - (**For `latest-V2.0.17`)

```bash
mf2c-curl-post https://localhost/api/device -d 
```

- **RESPONSES**
    - **201** - Success
    - **Response Payload:** 
    
```
{
   "deviceID": "438f508ee530a9694542441757faf40e991276c4fb59ba93bd1f51a265cf9b49e4d9c97793e141df7a04df388ef3a7a6d97b3a33133e860423634bbf4af604b4",
   "isLeader": false,
   "os": "Linux-4.15.0-48-generic-x86_64-with-debian-9.9",
   "arch": "x86_64",
   "cpuManufacturer": "Intel(R) Core(TM) i7-7700 CPU @ 3.60GHz",
   "physicalCores": 4,
   "logicalCores": 8,
   "cpuClockSpeed": "3.6000 GHz",
   "memory": 32127.988,
   "storage": 480584,
   "agentType": "Fog Agent",
   "networkingStandards": "enp0s31f6",
   "hwloc": "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<!DOCTYPE topology SYSTEM \"hwloc.dtd\">\n<topology>\n  <object type=\"Machine\" os_index=\"0\" cpuset=\"0x000000ff\" complete_cpuset=\"0x000000ff\" online_cpuset=\"0x000000ff\" allowed_cpuset=\"0x000000ff\" local_memory=\"33688637440\">\n    <page_type size=\"4096\" count=\"8224765\"/>\n    <page_type size=\"2097152\" count=\"0\"/>\n    <page_type size=\"1073741824\" count=\"0\"/>\n    <info name=\"DMIProductName\" value=\"MS-7A72\"/>\n    <info name=\"DMIProductVersion\" value=\"1.0\"/>\n    <info name=\"DMIProductSerial\" value=\"Default string\"/>\n    <info name=\"DMIProductUUID\" value=\"00000000-0000-0000-0000-4CCC6AF5A3EA\"/>\n    <info name=\"DMIBoardVendor\" value=\"MSI\"/>\n    <info name=\"DMIBoardName\" value=\"H270 PC MATE (MS-7A72)\"/>\n    <info name=\"DMIBoardVersion\" value=\"1.0\"/>\n    <info name=\"DMIBoardSerial\" value=\"H216677116\"/>\n    <info name=\"DMIBoardAssetTag\" value=\"Default string\"/>\n    <info name=\"DMIChassisVendor\" value=\"MSI\"/>\n    <info name=\"DMIChassisType\" value=\"3\"/>\n    <info name=\"DMIChassisVersion\" value=\"1.0\"/>\n    <info name=\"DMIChassisSerial\" value=\"Default string\"/>\n    <info name=\"DMIChassisAssetTag\" value=\"Default string\"/>\n    <info name=\"DMIBIOSVendor\" value=\"American Megatrends Inc.\"/>\n    <info name=\"DMIBIOSVersion\" value=\"2.60\"/>\n    <info name=\"DMIBIOSDate\" value=\"11/16/2017\"/>\n    <info name=\"DMISysVendor\" value=\"MSI\"/>\n    <info name=\"Backend\" value=\"Linux\"/>\n    <info name=\"LinuxCgroup\" value=\"/docker/a2e4cf59961bc6980d0057d8322a019c3e7923843583602a4cb7b3f039b58f14\"/>\n    <info name=\"OSName\" value=\"Linux\"/>\n    <info name=\"OSRelease\" value=\"4.15.0-48-generic\"/>\n    <info name=\"OSVersion\" value=\"#51~16.04.1-Ubuntu SMP Fri Apr 5 12:01:12 UTC 2019\"/>\n    <info name=\"HostName\" value=\"a2e4cf59961b\"/>\n    <info name=\"Architecture\" value=\"x86_64\"/>\n    <info name=\"hwlocVersion\" value=\"1.11.5\"/>\n    <info name=\"ProcessName\" value=\"hwloc-ls\"/>\n    <object type=\"Package\" os_index=\"0\" cpuset=\"0x000000ff\" complete_cpuset=\"0x000000ff\" online_cpuset=\"0x000000ff\" allowed_cpuset=\"0x000000ff\">\n      <info name=\"CPUVendor\" value=\"GenuineIntel\"/>\n      <info name=\"CPUFamilyNumber\" value=\"6\"/>\n      <info name=\"CPUModelNumber\" value=\"158\"/>\n      <info name=\"CPUModel\" value=\"Intel(R) Core(TM) i7-7700 CPU @ 3.60GHz\"/>\n      <info name=\"CPUStepping\" value=\"9\"/>\n      <object type=\"Cache\" cpuset=\"0x000000ff\" complete_cpuset=\"0x000000ff\" online_cpuset=\"0x000000ff\" allowed_cpuset=\"0x000000ff\" cache_size=\"8388608\" depth=\"3\" cache_linesize=\"64\" cache_associativity=\"16\" cache_type=\"0\">\n        <info name=\"Inclusive\" value=\"1\"/>\n        <object type=\"Cache\" cpuset=\"0x00000011\" complete_cpuset=\"0x00000011\" online_cpuset=\"0x00000011\" allowed_cpuset=\"0x00000011\" cache_size=\"262144\" depth=\"2\" cache_linesize=\"64\" cache_associativity=\"4\" cache_type=\"0\">\n          <info name=\"Inclusive\" value=\"0\"/>\n          <object type=\"Cache\" cpuset=\"0x00000011\" complete_cpuset=\"0x00000011\" online_cpuset=\"0x00000011\" allowed_cpuset=\"0x00000011\" cache_size=\"32768\" depth=\"1\" cache_linesize=\"64\" cache_associativity=\"8\" cache_type=\"1\">\n            <info name=\"Inclusive\" value=\"0\"/>\n            <object type=\"Cache\" cpuset=\"0x00000011\" complete_cpuset=\"0x00000011\" online_cpuset=\"0x00000011\" allowed_cpuset=\"0x00000011\" cache_size=\"32768\" depth=\"1\" cache_linesize=\"64\" cache_associativity=\"8\" cache_type=\"2\">\n              <info name=\"Inclusive\" value=\"0\"/>\n              <object type=\"Core\" os_index=\"0\" cpuset=\"0x00000011\" complete_cpuset=\"0x00000011\" online_cpuset=\"0x00000011\" allowed_cpuset=\"0x00000011\">\n                <object type=\"PU\" os_index=\"0\" cpuset=\"0x00000001\" complete_cpuset=\"0x00000001\" online_cpuset=\"0x00000001\" allowed_cpuset=\"0x00000001\"/>\n                <object type=\"PU\" os_index=\"4\" cpuset=\"0x00000010\" complete_cpuset=\"0x00000010\" online_cpuset=\"0x00000010\" allowed_cpuset=\"0x00000010\"/>\n              <\/object>\n            <\/object>\n          <\/object>\n        <\/object>\n        <object type=\"Cache\" cpuset=\"0x00000022\" complete_cpuset=\"0x00000022\" online_cpuset=\"0x00000022\" allowed_cpuset=\"0x00000022\" cache_size=\"262144\" depth=\"2\" cache_linesize=\"64\" cache_associativity=\"4\" cache_type=\"0\">\n          <info name=\"Inclusive\" value=\"0\"/>\n          <object type=\"Cache\" cpuset=\"0x00000022\" complete_cpuset=\"0x00000022\" online_cpuset=\"0x00000022\" allowed_cpuset=\"0x00000022\" cache_size=\"32768\" depth=\"1\" cache_linesize=\"64\" cache_associativity=\"8\" cache_type=\"1\">\n            <info name=\"Inclusive\" value=\"0\"/>\n            <object type=\"Cache\" cpuset=\"0x00000022\" complete_cpuset=\"0x00000022\" online_cpuset=\"0x00000022\" allowed_cpuset=\"0x00000022\" cache_size=\"32768\" depth=\"1\" cache_linesize=\"64\" cache_associativity=\"8\" cache_type=\"2\">\n              <info name=\"Inclusive\" value=\"0\"/>\n              <object type=\"Core\" os_index=\"1\" cpuset=\"0x00000022\" complete_cpuset=\"0x00000022\" online_cpuset=\"0x00000022\" allowed_cpuset=\"0x00000022\">\n                <object type=\"PU\" os_index=\"1\" cpuset=\"0x00000002\" complete_cpuset=\"0x00000002\" online_cpuset=\"0x00000002\" allowed_cpuset=\"0x00000002\"/>\n                <object type=\"PU\" os_index=\"5\" cpuset=\"0x00000020\" complete_cpuset=\"0x00000020\" online_cpuset=\"0x00000020\" allowed_cpuset=\"0x00000020\"/>\n              <\/object>\n            <\/object>\n          <\/object>\n        <\/object>\n        <object type=\"Cache\" cpuset=\"0x00000044\" complete_cpuset=\"0x00000044\" online_cpuset=\"0x00000044\" allowed_cpuset=\"0x00000044\" cache_size=\"262144\" depth=\"2\" cache_linesize=\"64\" cache_associativity=\"4\" cache_type=\"0\">\n          <info name=\"Inclusive\" value=\"0\"/>\n          <object type=\"Cache\" cpuset=\"0x00000044\" complete_cpuset=\"0x00000044\" online_cpuset=\"0x00000044\" allowed_cpuset=\"0x00000044\" cache_size=\"32768\" depth=\"1\" cache_linesize=\"64\" cache_associativity=\"8\" cache_type=\"1\">\n            <info name=\"Inclusive\" value=\"0\"/>\n            <object type=\"Cache\" cpuset=\"0x00000044\" complete_cpuset=\"0x00000044\" online_cpuset=\"0x00000044\" allowed_cpuset=\"0x00000044\" cache_size=\"32768\" depth=\"1\" cache_linesize=\"64\" cache_associativity=\"8\" cache_type=\"2\">\n              <info name=\"Inclusive\" value=\"0\"/>\n              <object type=\"Core\" os_index=\"2\" cpuset=\"0x00000044\" complete_cpuset=\"0x00000044\" online_cpuset=\"0x00000044\" allowed_cpuset=\"0x00000044\">\n                <object type=\"PU\" os_index=\"2\" cpuset=\"0x00000004\" complete_cpuset=\"0x00000004\" online_cpuset=\"0x00000004\" allowed_cpuset=\"0x00000004\"/>\n                <object type=\"PU\" os_index=\"6\" cpuset=\"0x00000040\" complete_cpuset=\"0x00000040\" online_cpuset=\"0x00000040\" allowed_cpuset=\"0x00000040\"/>\n              <\/object>\n            <\/object>\n          <\/object>\n        <\/object>\n        <object type=\"Cache\" cpuset=\"0x00000088\" complete_cpuset=\"0x00000088\" online_cpuset=\"0x00000088\" allowed_cpuset=\"0x00000088\" cache_size=\"262144\" depth=\"2\" cache_linesize=\"64\" cache_associativity=\"4\" cache_type=\"0\">\n          <info name=\"Inclusive\" value=\"0\"/>\n          <object type=\"Cache\" cpuset=\"0x00000088\" complete_cpuset=\"0x00000088\" online_cpuset=\"0x00000088\" allowed_cpuset=\"0x00000088\" cache_size=\"32768\" depth=\"1\" cache_linesize=\"64\" cache_associativity=\"8\" cache_type=\"1\">\n            <info name=\"Inclusive\" value=\"0\"/>\n            <object type=\"Cache\" cpuset=\"0x00000088\" complete_cpuset=\"0x00000088\" online_cpuset=\"0x00000088\" allowed_cpuset=\"0x00000088\" cache_size=\"32768\" depth=\"1\" cache_linesize=\"64\" cache_associativity=\"8\" cache_type=\"2\">\n              <info name=\"Inclusive\" value=\"0\"/>\n              <object type=\"Core\" os_index=\"3\" cpuset=\"0x00000088\" complete_cpuset=\"0x00000088\" online_cpuset=\"0x00000088\" allowed_cpuset=\"0x00000088\">\n                <object type=\"PU\" os_index=\"3\" cpuset=\"0x00000008\" complete_cpuset=\"0x00000008\" online_cpuset=\"0x00000008\" allowed_cpuset=\"0x00000008\"/>\n                <object type=\"PU\" os_index=\"7\" cpuset=\"0x00000080\" complete_cpuset=\"0x00000080\" online_cpuset=\"0x00000080\" allowed_cpuset=\"0x00000080\"/>\n              <\/object>\n            <\/object>\n          <\/object>\n        <\/object>\n      <\/object>\n    <\/object>\n    <object type=\"Bridge\" os_index=\"0\" bridge_type=\"0-1\" depth=\"0\" bridge_pci=\"0000:[00-04]\">\n      <object type=\"Bridge\" os_index=\"16\" bridge_type=\"1-1\" depth=\"1\" bridge_pci=\"0000:[01-01]\" pci_busid=\"0000:00:01.0\" pci_type=\"0604 [8086:1901] [1462:7a72] 05\" pci_link_speed=\"4.000000\">\n        <object type=\"PCIDev\" os_index=\"4096\" pci_busid=\"0000:01:00.0\" pci_type=\"0300 [10de:1287] [1458:3666] a1\" pci_link_speed=\"4.000000\">\n          <object type=\"OSDev\" name=\"renderD128\" osdev_type=\"1\"/>\n          <object type=\"OSDev\" name=\"controlD64\" osdev_type=\"1\"/>\n          <object type=\"OSDev\" name=\"card0\" osdev_type=\"1\"/>\n        <\/object>\n      <\/object>\n      <object type=\"PCIDev\" os_index=\"368\" pci_busid=\"0000:00:17.0\" pci_type=\"0106 [8086:a282] [1462:7a72] 00\" pci_link_speed=\"0.000000\">\n        <object type=\"OSDev\" name=\"sda\" osdev_type=\"0\">\n          <info name=\"LinuxDeviceID\" value=\"8:0\"/>\n        <\/object>\n        <object type=\"OSDev\" name=\"sr0\" osdev_type=\"0\">\n          <info name=\"LinuxDeviceID\" value=\"11:0\"/>\n        <\/object>\n      <\/object>\n      <object type=\"PCIDev\" os_index=\"502\" pci_busid=\"0000:00:1f.6\" pci_type=\"0200 [8086:15b8] [1462:7a72] 00\" pci_link_speed=\"0.000000\"/>\n    <\/object>\n  <\/object>\n<\/topology>\n",
   "cpuinfo": "processor\t: 0\nvendor_id\t: GenuineIntel\ncpu family\t: 6\nmodel\t\t: 158\nmodel name\t: Intel(R) Core(TM) i7-7700 CPU @ 3.60GHz\nstepping\t: 9\nmicrocode\t: 0xb4\ncpu MHz\t\t: 3821.606\ncache size\t: 8192 KB\nphysical id\t: 0\nsiblings\t: 8\ncore id\t\t: 0\ncpu cores\t: 4\napicid\t\t: 0\ninitial apicid\t: 0\nfpu\t\t: yes\nfpu_exception\t: yes\ncpuid level\t: 22\nwp\t\t: yes\nflags\t\t: fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe syscall nx pdpe1gb rdtscp lm constant_tsc art arch_perfmon pebs bts rep_good nopl xtopology nonstop_tsc cpuid aperfmperf tsc_known_freq pni pclmulqdq dtes64 monitor ds_cpl vmx smx est tm2 ssse3 sdbg fma cx16 xtpr pdcm pcid sse4_1 sse4_2 x2apic movbe popcnt tsc_deadline_timer aes xsave avx f16c rdrand lahf_lm abm 3dnowprefetch cpuid_fault invpcid_single pti ssbd ibrs ibpb stibp tpr_shadow vnmi flexpriority ept vpid fsgsbase tsc_adjust bmi1 hle avx2 smep bmi2 erms invpcid rtm mpx rdseed adx smap clflushopt intel_pt xsaveopt xsavec xgetbv1 xsaves dtherm ida arat pln pts hwp hwp_notify hwp_act_window hwp_epp flush_l1d\nbugs\t\t: cpu_meltdown spectre_v1 spectre_v2 spec_store_bypass l1tf\nbogomips\t: 7200.00\nclflush size\t: 64\ncache_alignment\t: 64\naddress sizes\t: 39 bits physical, 48 bits virtual\npower management:\n\nprocessor\t: 1\nvendor_id\t: GenuineIntel\ncpu family\t: 6\nmodel\t\t: 158\nmodel name\t: Intel(R) Core(TM) i7-7700 CPU @ 3.60GHz\nstepping\t: 9\nmicrocode\t: 0xb4\ncpu MHz\t\t: 3823.348\ncache size\t: 8192 KB\nphysical id\t: 0\nsiblings\t: 8\ncore id\t\t: 1\ncpu cores\t: 4\napicid\t\t: 2\ninitial apicid\t: 2\nfpu\t\t: yes\nfpu_exception\t: yes\ncpuid level\t: 22\nwp\t\t: yes\nflags\t\t: fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe syscall nx pdpe1gb rdtscp lm constant_tsc art arch_perfmon pebs bts rep_good nopl xtopology nonstop_tsc cpuid aperfmperf tsc_known_freq pni pclmulqdq dtes64 monitor ds_cpl vmx smx est tm2 ssse3 sdbg fma cx16 xtpr pdcm pcid sse4_1 sse4_2 x2apic movbe popcnt tsc_deadline_timer aes xsave avx f16c rdrand lahf_lm abm 3dnowprefetch cpuid_fault invpcid_single pti ssbd ibrs ibpb stibp tpr_shadow vnmi flexpriority ept vpid fsgsbase tsc_adjust bmi1 hle avx2 smep bmi2 erms invpcid rtm mpx rdseed adx smap clflushopt intel_pt xsaveopt xsavec xgetbv1 xsaves dtherm ida arat pln pts hwp hwp_notify hwp_act_window hwp_epp flush_l1d\nbugs\t\t: cpu_meltdown spectre_v1 spectre_v2 spec_store_bypass l1tf\nbogomips\t: 7200.00\nclflush size\t: 64\ncache_alignment\t: 64\naddress sizes\t: 39 bits physical, 48 bits virtual\npower management:\n\nprocessor\t: 2\nvendor_id\t: GenuineIntel\ncpu family\t: 6\nmodel\t\t: 158\nmodel name\t: Intel(R) Core(TM) i7-7700 CPU @ 3.60GHz\nstepping\t: 9\nmicrocode\t: 0xb4\ncpu MHz\t\t: 3823.727\ncache size\t: 8192 KB\nphysical id\t: 0\nsiblings\t: 8\ncore id\t\t: 2\ncpu cores\t: 4\napicid\t\t: 4\ninitial apicid\t: 4\nfpu\t\t: yes\nfpu_exception\t: yes\ncpuid level\t: 22\nwp\t\t: yes\nflags\t\t: fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe syscall nx pdpe1gb rdtscp lm constant_tsc art arch_perfmon pebs bts rep_good nopl xtopology nonstop_tsc cpuid aperfmperf tsc_known_freq pni pclmulqdq dtes64 monitor ds_cpl vmx smx est tm2 ssse3 sdbg fma cx16 xtpr pdcm pcid sse4_1 sse4_2 x2apic movbe popcnt tsc_deadline_timer aes xsave avx f16c rdrand lahf_lm abm 3dnowprefetch cpuid_fault invpcid_single pti ssbd ibrs ibpb stibp tpr_shadow vnmi flexpriority ept vpid fsgsbase tsc_adjust bmi1 hle avx2 smep bmi2 erms invpcid rtm mpx rdseed adx smap clflushopt intel_pt xsaveopt xsavec xgetbv1 xsaves dtherm ida arat pln pts hwp hwp_notify hwp_act_window hwp_epp flush_l1d\nbugs\t\t: cpu_meltdown spectre_v1 spectre_v2 spec_store_bypass l1tf\nbogomips\t: 7200.00\nclflush size\t: 64\ncache_alignment\t: 64\naddress sizes\t: 39 bits physical, 48 bits virtual\npower management:\n\nprocessor\t: 3\nvendor_id\t: GenuineIntel\ncpu family\t: 6\nmodel\t\t: 158\nmodel name\t: Intel(R) Core(TM) i7-7700 CPU @ 3.60GHz\nstepping\t: 9\nmicrocode\t: 0xb4\ncpu MHz\t\t: 3822.621\ncache size\t: 8192 KB\nphysical id\t: 0\nsiblings\t: 8\ncore id\t\t: 3\ncpu cores\t: 4\napicid\t\t: 6\ninitial apicid\t: 6\nfpu\t\t: yes\nfpu_exception\t: yes\ncpuid level\t: 22\nwp\t\t: yes\nflags\t\t: fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe syscall nx pdpe1gb rdtscp lm constant_tsc art arch_perfmon pebs bts rep_good nopl xtopology nonstop_tsc cpuid aperfmperf tsc_known_freq pni pclmulqdq dtes64 monitor ds_cpl vmx smx est tm2 ssse3 sdbg fma cx16 xtpr pdcm pcid sse4_1 sse4_2 x2apic movbe popcnt tsc_deadline_timer aes xsave avx f16c rdrand lahf_lm abm 3dnowprefetch cpuid_fault invpcid_single pti ssbd ibrs ibpb stibp tpr_shadow vnmi flexpriority ept vpid fsgsbase tsc_adjust bmi1 hle avx2 smep bmi2 erms invpcid rtm mpx rdseed adx smap clflushopt intel_pt xsaveopt xsavec xgetbv1 xsaves dtherm ida arat pln pts hwp hwp_notify hwp_act_window hwp_epp flush_l1d\nbugs\t\t: cpu_meltdown spectre_v1 spectre_v2 spec_store_bypass l1tf\nbogomips\t: 7200.00\nclflush size\t: 64\ncache_alignment\t: 64\naddress sizes\t: 39 bits physical, 48 bits virtual\npower management:\n\nprocessor\t: 4\nvendor_id\t: GenuineIntel\ncpu family\t: 6\nmodel\t\t: 158\nmodel name\t: Intel(R) Core(TM) i7-7700 CPU @ 3.60GHz\nstepping\t: 9\nmicrocode\t: 0xb4\ncpu MHz\t\t: 3822.299\ncache size\t: 8192 KB\nphysical id\t: 0\nsiblings\t: 8\ncore id\t\t: 0\ncpu cores\t: 4\napicid\t\t: 1\ninitial apicid\t: 1\nfpu\t\t: yes\nfpu_exception\t: yes\ncpuid level\t: 22\nwp\t\t: yes\nflags\t\t: fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe syscall nx pdpe1gb rdtscp lm constant_tsc art arch_perfmon pebs bts rep_good nopl xtopology nonstop_tsc cpuid aperfmperf tsc_known_freq pni pclmulqdq dtes64 monitor ds_cpl vmx smx est tm2 ssse3 sdbg fma cx16 xtpr pdcm pcid sse4_1 sse4_2 x2apic movbe popcnt tsc_deadline_timer aes xsave avx f16c rdrand lahf_lm abm 3dnowprefetch cpuid_fault invpcid_single pti ssbd ibrs ibpb stibp tpr_shadow vnmi flexpriority ept vpid fsgsbase tsc_adjust bmi1 hle avx2 smep bmi2 erms invpcid rtm mpx rdseed adx smap clflushopt intel_pt xsaveopt xsavec xgetbv1 xsaves dtherm ida arat pln pts hwp hwp_notify hwp_act_window hwp_epp flush_l1d\nbugs\t\t: cpu_meltdown spectre_v1 spectre_v2 spec_store_bypass l1tf\nbogomips\t: 7200.00\nclflush size\t: 64\ncache_alignment\t: 64\naddress sizes\t: 39 bits physical, 48 bits virtual\npower management:\n\nprocessor\t: 5\nvendor_id\t: GenuineIntel\ncpu family\t: 6\nmodel\t\t: 158\nmodel name\t: Intel(R) Core(TM) i7-7700 CPU @ 3.60GHz\nstepping\t: 9\nmicrocode\t: 0xb4\ncpu MHz\t\t: 3822.359\ncache size\t: 8192 KB\nphysical id\t: 0\nsiblings\t: 8\ncore id\t\t: 1\ncpu cores\t: 4\napicid\t\t: 3\ninitial apicid\t: 3\nfpu\t\t: yes\nfpu_exception\t: yes\ncpuid level\t: 22\nwp\t\t: yes\nflags\t\t: fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe syscall nx pdpe1gb rdtscp lm constant_tsc art arch_perfmon pebs bts rep_good nopl xtopology nonstop_tsc cpuid aperfmperf tsc_known_freq pni pclmulqdq dtes64 monitor ds_cpl vmx smx est tm2 ssse3 sdbg fma cx16 xtpr pdcm pcid sse4_1 sse4_2 x2apic movbe popcnt tsc_deadline_timer aes xsave avx f16c rdrand lahf_lm abm 3dnowprefetch cpuid_fault invpcid_single pti ssbd ibrs ibpb stibp tpr_shadow vnmi flexpriority ept vpid fsgsbase tsc_adjust bmi1 hle avx2 smep bmi2 erms invpcid rtm mpx rdseed adx smap clflushopt intel_pt xsaveopt xsavec xgetbv1 xsaves dtherm ida arat pln pts hwp hwp_notify hwp_act_window hwp_epp flush_l1d\nbugs\t\t: cpu_meltdown spectre_v1 spectre_v2 spec_store_bypass l1tf\nbogomips\t: 7200.00\nclflush size\t: 64\ncache_alignment\t: 64\naddress sizes\t: 39 bits physical, 48 bits virtual\npower management:\n\nprocessor\t: 6\nvendor_id\t: GenuineIntel\ncpu family\t: 6\nmodel\t\t: 158\nmodel name\t: Intel(R) Core(TM) i7-7700 CPU @ 3.60GHz\nstepping\t: 9\nmicrocode\t: 0xb4\ncpu MHz\t\t: 3820.759\ncache size\t: 8192 KB\nphysical id\t: 0\nsiblings\t: 8\ncore id\t\t: 2\ncpu cores\t: 4\napicid\t\t: 5\ninitial apicid\t: 5\nfpu\t\t: yes\nfpu_exception\t: yes\ncpuid level\t: 22\nwp\t\t: yes\nflags\t\t: fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe syscall nx pdpe1gb rdtscp lm constant_tsc art arch_perfmon pebs bts rep_good nopl xtopology nonstop_tsc cpuid aperfmperf tsc_known_freq pni pclmulqdq dtes64 monitor ds_cpl vmx smx est tm2 ssse3 sdbg fma cx16 xtpr pdcm pcid sse4_1 sse4_2 x2apic movbe popcnt tsc_deadline_timer aes xsave avx f16c rdrand lahf_lm abm 3dnowprefetch cpuid_fault invpcid_single pti ssbd ibrs ibpb stibp tpr_shadow vnmi flexpriority ept vpid fsgsbase tsc_adjust bmi1 hle avx2 smep bmi2 erms invpcid rtm mpx rdseed adx smap clflushopt intel_pt xsaveopt xsavec xgetbv1 xsaves dtherm ida arat pln pts hwp hwp_notify hwp_act_window hwp_epp flush_l1d\nbugs\t\t: cpu_meltdown spectre_v1 spectre_v2 spec_store_bypass l1tf\nbogomips\t: 7200.00\nclflush size\t: 64\ncache_alignment\t: 64\naddress sizes\t: 39 bits physical, 48 bits virtual\npower management:\n\nprocessor\t: 7\nvendor_id\t: GenuineIntel\ncpu family\t: 6\nmodel\t\t: 158\nmodel name\t: Intel(R) Core(TM) i7-7700 CPU @ 3.60GHz\nstepping\t: 9\nmicrocode\t: 0xb4\ncpu MHz\t\t: 3823.942\ncache size\t: 8192 KB\nphysical id\t: 0\nsiblings\t: 8\ncore id\t\t: 3\ncpu cores\t: 4\napicid\t\t: 7\ninitial apicid\t: 7\nfpu\t\t: yes\nfpu_exception\t: yes\ncpuid level\t: 22\nwp\t\t: yes\nflags\t\t: fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe syscall nx pdpe1gb rdtscp lm constant_tsc art arch_perfmon pebs bts rep_good nopl xtopology nonstop_tsc cpuid aperfmperf tsc_known_freq pni pclmulqdq dtes64 monitor ds_cpl vmx smx est tm2 ssse3 sdbg fma cx16 xtpr pdcm pcid sse4_1 sse4_2 x2apic movbe popcnt tsc_deadline_timer aes xsave avx f16c rdrand lahf_lm abm 3dnowprefetch cpuid_fault invpcid_single pti ssbd ibrs ibpb stibp tpr_shadow vnmi flexpriority ept vpid fsgsbase tsc_adjust bmi1 hle avx2 smep bmi2 erms invpcid rtm mpx rdseed adx smap clflushopt intel_pt xsaveopt xsavec xgetbv1 xsaves dtherm ida arat pln pts hwp hwp_notify hwp_act_window hwp_epp flush_l1d\nbugs\t\t: cpu_meltdown spectre_v1 spectre_v2 spec_store_bypass l1tf\nbogomips\t: 7200.00\nclflush size\t: 64\ncache_alignment\t: 64\naddress sizes\t: 39 bits physical, 48 bits virtual\npower management:\n\n",
}
```

- **GET**  device-dynamic information - (**For `latest-V2.0.17` \& later)

```bash
curl -X GET "http://localhost/api/device-dynamic" -H "accept: application/json"
```

- **RESPONSES**
    - **200** - Success
    - **Response Payload:** 

 ```
{
   "count": 1,
   "acl": {
      "owner": {
         "principal": "ADMIN",
         "type": "ROLE"
      },
      "rules": [
         {
            "principal": "USER",
            "type": "ROLE",
            "right": "MODIFY"
         }
      ]
   },
   "resourceURI": "http://schemas.dmtf.org/cimi/2/DeviceDynamicCollection",
   "id": "device-dynamic",
   "operations": [
      {
         "rel": "add",
         "href": "device-dynamic"
      }
   ],
   "deviceDynamics": [
      {
         "powerPlugged": true,
         "wifiAddress": "Null",
         "ramFree": 16276.719,
         "ethernetAddress": "147.83.159.210",
         "updated": "2019-05-22T10:10:10.270Z",
         "created": "2019-05-22T10:10:10.270Z",
         "sensors": [
            {
               "sensorType": [
                  "acceleration",
                  "satelliteCount",
                  "voltage",
                  "battery",
                  "inclination",
                  "proximity",
                  "bearing",
                  "velocity",
                  "current",
                  "waterLevel",
                  "temperature",
                  "humidity",
                  "pressure",
                  "latitude",
                  "longitude"
               ],
               "sensorConnection": "[\"{\"bluetoothMac\": \"12:23:34:45:56:67\"}\"]",
               "sensorModel": [
                  "smartboat-bm"
               ]
            }
         ],
         "storageFreePercent": 90.4,
         "wifiThroughputInfo": [
            "E",
            "m",
            "p",
            "t",
            "y"
         ],
         "id": "device-dynamic/2b96787c-e42f-4fa6-9c91-2daab893fff7",
         "ethernetThroughputInfo": [
            " RX packets:9530693 ",
            " TX packets:2098910 "
         ],
         "powerRemainingStatus": "Unlimited",
         "cpuFreePercent": 6.7,
         "acl": {
            "owner": {
               "principal": "ADMIN",
               "type": "ROLE"
            }
         },
         "operations": [
            {
               "rel": "edit",
               "href": "device-dynamic/2b96787c-e42f-4fa6-9c91-2daab893fff7"
            },
            {
               "rel": "delete",
               "href": "device-dynamic/2b96787c-e42f-4fa6-9c91-2daab893fff7"
            }
         ],
         "actuatorInfo": "It has Traffic light",
         "resourceURI": "http://schemas.dmtf.org/cimi/2/DeviceDynamic",
         "device": {
            "href": "device/7af201c2-f7fe-410d-92bd-c18eca9444ff"
         },
         "ramFreePercent": 50.7,
         "powerRemainingStatusSeconds": "Unlimited",
         "storageFree": 412231.28
         "status": "connected"
      }
   ]
}
```

- **POST**  device-dynamic information - (**For `latest-V2.0.17`)

```bash
mf2c-curl-post https://localhost/api/device-dynamic -d 
```

- **RESPONSES**
    - **201** - Success
    - **Response Payload:** 
    
```
{
   "device": {
      "href": "device/7af201c2-f7fe-410d-92bd-c18eca9444ff"
   },
   "ramFree": 16276.719,
   "ramFreePercent": 50.7,
   "storageFree": 412231.28,
   "storageFreePercent": 90.4,
   "cpuFreePercent": 6.7,
   "powerRemainingStatus": "Unlimited",
   "powerRemainingStatusSeconds": "Unlimited",
   "powerPlugged": true,
   "actuatorInfo": "It has Traffic light",
   "status": "connected",
   "ethernetAddress": "147.83.159.210",
   "wifiAddress": "Null",
   "ethernetThroughputInfo": [
      " RX packets:9530693 ",
      " TX packets:2098910 "
   ],
   "wifiThroughputInfo": [
      "E",
      "m",
      "p",
      "t",
      "y"
   ],
   "sensors": [
      {
         "sensorType": [
            "acceleration",
            "satelliteCount",
            "voltage",
            "battery",
            "inclination",
            "proximity",
            "bearing",
            "velocity",
            "current",
            "waterLevel",
            "temperature",
            "humidity",
            "pressure",
            "latitude",
            "longitude"
         ],
         "sensorModel": [
            "smartboat-bm"
         ],
         "sensorConnection": "[\"{\"bluetoothMac\": \"12:23:34:45:56:67\"}\"]"
      }
   ]
}
```


- **GET**  fog-area information - (**For `latest-V2.0.18` \& later)
```bash
curl -X GET "http://localhost/api/fog-area" -H "accept: application/json"
```

- **RESPONSES**
    - **200** - Success
    - **Response Payload:**
```     
{
    "count": 1, 
    "acl": {
        "owner": {
            "principal": 'ADMIN', 
            "type": "ROLE"
            }, 
            "rules": [{
                "principal": "USER", 
                "type": "ROLE", 
                "right": "MODIFY"
                }]}, 
                "resourceURI": "http://schemas.dmtf.org/cimi/2/FogAreaCollection", 
                "id': fog-area", 
                "operations": [{
                    "rel": "add", 
                    "href": "fog-area"
                    }], 
                    "fogAreas": [{
                        "logicalCoresMax": 8, 
                        "avgLogicalCores": 8, 
                        "cpuMinPercent": 70.1, 
                        "storageMin": 211773.75390625, 
                        "avgProcessingCapacityPercent": 70.1, 
                        "updated": "2019-07-10T08:49:12.738Z", 
                        "ramTotal": 21845.33984375, 
                        "ramMin": 21845.33984375, 
                        "storageTotal": 211773.75390625, 
                        "created": '2019-07-10T08:49:12.738Z', 
                        "storageMax": 211773.75390625, 
                        "numDevices": 1, 
                        "physicalCoresMax": 4, 
                        "leaderDevice": {
                            "href": "device/f463558d-0604-4f70-b215-7dc6e6f9d4dd"
                            }, 
                           "logicalCoresMin": 8, 
                           "physicalCoresMin": 4, 
                           "id": "fog-area/ef91c756-ff7a-4a2b-b6c0-644f0d9266ae", 
                           "cpuMaxPercent": 70.1, 
                           "powerRemainingMax": "one or more devices has/have external power sources", 
                           "acl": {
                            "owner": {
                                "principal": "ADMIN", 
                                "type": "ROLE"
                                }}, 
                                "operations": [{
                                    "rel": "edit", 
                                    "href": "fog-area/ef91c756-ff7a-4a2b-b6c0-644f0d9266ae"
                                    }, 
                                    {
                                    "rel": "delete", 
                                    "href": "fog-area/ef91c756-ff7a-4a2b-b6c0-644f0d9266ae"
                                    }], 
                                    "resourceURI": "http://schemas.dmtf.org/cimi/2/FogArea", 
                                    "ramMax": 21845.33984375, 
                                    "powerRemainingMin": "100.0", 
                                    "avgPhysicalCores": 4
                                   }
                                 ]

}
```




- **POST**  fog-area information - (**For `latest-V2.0.18` \& later)
```bash
mf2c-curl-post https://localhost/api/fog-area -d
```

- **RESPONSES**
    - **200** - Success
    - **Response Payload:**
```     
{
    "leaderDevice": {
        "href": "device/497bb5e1-4138-411b-ab61-c70c925688a9"}, 
    "numDevices": 2, 
    "ramTotal": 42600.34765625, 
    "ramMax": 21622.45703125, 
    "ramMin": 20977.890625, 
    "storageTotal": 423830.33984375, 
    "storageMax": 211987.1015625, 
    "storageMin": 211843.23828125, 
    "avgProcessingCapacityPercent": 83.45, 
    "cpuMaxPercent": 86.9, 
    "cpuMinPercent": 80.0, 
    "avgPhysicalCores": 4, 
    "physicalCoresMax": 4, 
    "physicalCoresMin": 4, 
    "avgLogicalCores": 8, 
    "logicalCoresMax": 8, 
    "logicalCoresMin": 8, 
    "powerRemainingMax": "one or more devices has/have external power sources", 
    "powerRemainingMin": "100.0"
}
```

### Special Note*

- For those, who are using the `latest-V2.0.16` tagged `docker-image` for `resource-categorization` module, before testing the `resource-categorization` component and `POST` the uppermentioned information, it is necessary to add the `status` filed to the `device` and need to remove the `status` filed from `device-dynamic`

### Troubleshooting

- For those who are using `latest-V2.0.16`; To get the `Host-IP` related information the resource-categorization module is running another container `alpine:latest` . So it might possible that sometimes we may not be able to get the output value from that container.
- Fix the multiple `device_ip` creation issue for a single agent

## Change LOG

 ### latest-V2.0.20 (date 19/September/2019) [in complience with CIMI-server - 2.27 +later & DataClay version - 2.23 +later]
 
#### Added
 - Fixed the `deviceIP` related issues for both `leader` and `child` agent side
 
 #### Changed 
  - Nothing has been changed compare to previous version, except the `deviceIP` related issue has been fully solved

 
 ### latest-V2.0.19 (date 30/July/2019) [in complience with CIMI-server - 2.23 +later & DataClay version - 2.22 +later]
 
 #### Added

  - Added the functionality to retrieve the `deviceIP` from `discovery` module

#### Changed

- Nothing has been changed compare to previous version, only partially fixed the `deviceIP` related issue  

 ### latest-V2.0.18 (date 09/July/2019) [in complience with CIMI-server - 2.20 +later & DataClay version - 2.22 +later]
 
  #### Added

   - Added the `childips` info in the leader agent

  #### Changed

   - In the leader agent side the resource-categorization module is now adding/updating the `agent-resource` information
   

 ### latest-V2.0.17 (date 28/June/2019) [in complience with CIMI-server - 2.20 +later & DataClay version - 2.22]
   
  #### Added

   - Already added the `status` info in the `device-dynamic`
   
  #### Changed
  - For latest-V2.0.17 moved the `status` info from `device` to `device-dynamic`
   
   
 ### latest-V2.0.16 (date 28/June/2019) [in complience with CIMI-server - 2.18 / 2.19 & DataClay version - 2.21]
 
 
 ## Work in progress
 
 - Making a connection between `VPN-Client` and `Resource-Categorization` module; So that, in case of the failure of `discovery` module the `Resource-Categorization` can retrieve the `deviceIP` from `VPN-Client`







