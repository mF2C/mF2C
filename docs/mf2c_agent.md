# mF2C Agent

Set of all modules composing the mF2C agent

## Usage

Executing the hello-world test:

        cd docker-compose
        docker-compose -p mf2c up -d
        ./hello-world.sh

### API

 - GUI for executing services locally `https://localhost/sm/index.html`

### Troubleshooting

 - hello-world script (single-agent) fails when executed right after the agent is started. The waiting time for no failures is ~2-5 min, depending on the machine.
 - Sometimes hello-world fails because landscaper does not get any device-dynamic registered on time. Restarting landscaper solves the issue.
 - (agent version PR #204) Sometimes dcproxy (ver. 2.22) terminates with exit code 1. To solve the issue, the agent needs to be restarted until dcproxy is running and stable.

### Known issues

 - (multi-agent) when executing agent with "isLeader=True" and "leaderIP=", the address registered in `device-dynamic` is not correct.
 - (agent version PR #204) landscaper terminates with exit code 1. Component restart does not solve the problem.

## CHANGELOG

### 1.0.1 (28.06.19)

#### Changed

 - Fixes random failures during the execution of the hello-world (single-agent)

### 1.0 (26.06.19)

#### Added

 - First release running hello-world (single-agent) 

## Tests

#### Agent version
- The tests were performed on agent version PR #204.  

#### Test environment
- Single agent on VirtualBox VM, Linux Debian 8, 2 CPUs, 4GB RAM

#### Error logs 
In the following, the logs for containers that exited with an error code.
- dcproxy:2.22 (agent version PR #204):  
```
INFO: initializing dataclay  
2019-07-10T08:40:04,080 INFO [DataClay.api] [main] [DataClay:200] Session file not found or DATACLAYSESSIONCONFIG  not properly set Trying default location /root/dataclay/cfgfiles/session.properties  
java.lang.RuntimeException: Client is not able to connect to DataClay LogicModule  
        at dataclay.commonruntime.RuntimeUtils.checkConnection(RuntimeUtils.java:50)
	at dataclay.commonruntime.DataClayRuntime.checkConnectionAndParams(DataClayRuntime.java:710)  
	at dataclay.commonruntime.ClientManagementLib.getAccountID(ClientManagementLib.java:252)  
	at dataclay.tool.GetBackends.getBackends(GetBackends.java:50)  
	at dataclay.api.DataClay.initInternal(DataClay.java:228)  
	at dataclay.api.DataClay.init(DataClay.java:160)  
	at com.sixsq.dataclay.proxy$_main$fn__1221.invoke(proxy.clj:31)  
	at com.sixsq.dataclay.proxy$_main.invokeStatic(proxy.clj:29)  
	at com.sixsq.dataclay.proxy$_main.doInvoke(proxy.clj:28)  
	at clojure.lang.RestFn.invoke(RestFn.java:397)  
	at clojure.lang.AFn.applyToHelper(AFn.java:152)  
	at clojure.lang.RestFn.applyTo(RestFn.java:132)  
	at com.sixsq.dataclay.proxy.main(Unknown Source)  
Jul 10, 2019 8:40:24 AM com.sixsq.dataclay.proxy invoke  
SEVERE: error initializing dataClay: dataclay.api.DataClayException: java.lang.RuntimeException: Client is not able to connect to DataClay LogicModule  
Jul 10, 2019 8:40:24 AM com.sixsq.dataclay.proxy invoke  
SEVERE: halting service
```
- landscaper:0.6.5 (agent version PR #204), two errors occurred at different times:
```
starting landscaper
[2019-07-09 08:38:50 UTC] [INFO] : Generating hwloc and cpu_info files 
[2019-07-09 08:38:50 UTC] [ERROR] : Request failed: 502 
[2019-07-09 08:38:50 UTC] [ERROR] : Response: Bad Gateway 
[2019-07-09 08:38:50 UTC] [ERROR] : Request failed: 502 
Traceback (most recent call last):
  File "landscaper.py", line 21, in <module>
    MANAGER.start_landscaper()
  File "/landscaper/landscaper/landscape_manager.py", line 57, in start_landscaper
    self._initilise_graph_db()
  File "/landscaper/landscaper/landscape_manager.py", line 111, in _initilise_graph_db
    collector.init_graph_db()
  File "/landscaper/landscaper/collector/cimi_physicalhost_collector.py", line 63, in init_graph_db
    deviceDynamics = self.device_dynamic_dict()
  File "/landscaper/landscaper/collector/cimi_physicalhost_collector.py", line 186, in device_dynamic_dict
    deviceDynamics = self.get_device_dynamics()
  File "/landscaper/landscaper/collector/cimi_physicalhost_collector.py", line 182, in get_device_dynamics
    res = self.cimiClient.get_collection('device-dynamic')
  File "/landscaper/landscaper/utilities/cimi.py", line 82, in get_collection
    LOG.error("Response: " + str(res.json()))
  File "/usr/local/lib/python2.7/dist-packages/requests/models.py", line 897, in json
    return complexjson.loads(self.text, **kwargs)
  File "/usr/local/lib/python2.7/dist-packages/simplejson/__init__.py", line 518, in loads
    return _default_decoder.decode(s)
  File "/usr/local/lib/python2.7/dist-packages/simplejson/decoder.py", line 370, in decode
    obj, end = self.raw_decode(s)
  File "/usr/local/lib/python2.7/dist-packages/simplejson/decoder.py", line 400, in raw_decode
    return self.scan_once(s, idx=_w(s, idx).end())
simplejson.errors.JSONDecodeError: Expecting value: line 1 column 1 (char 0)
```

```
starting landscaper
[2019-07-09 08:10:25 UTC] [INFO] : Generating hwloc and cpu_info files 
[2019-07-09 08:10:26 UTC] [INFO] : CIMI Connection OK. Devices returned: 0 
[2019-07-09 08:10:26 UTC] [INFO] : Adding physical machines to the landscape... 
[2019-07-09 08:10:26 UTC] [INFO] : HWLocCollector - Adding machine: machine-A 
[2019-07-09 08:10:35 UTC] [INFO] : HWLocCollector - Adding machine: machine-B 
[2019-07-09 08:10:39 UTC] [INFO] : Finished adding physical machines to the landscape. 
[2019-07-09 08:10:39 UTC] [INFO] : ContainerCollector - Adding Docker infrastructure components to the landscape. 
Traceback (most recent call last):
  File "landscaper.py", line 21, in <module>
    MANAGER.start_landscaper()
  File "/landscaper/landscaper/landscape_manager.py", line 57, in start_landscaper
    self._initilise_graph_db()
  File "/landscaper/landscaper/landscape_manager.py", line 111, in _initilise_graph_db
    collector.init_graph_db()
  File "/landscaper/landscaper/collector/container_collector.py", line 63, in init_graph_db
    nodes = [x for x in self.swarm_manager.nodes.list() if
  File "/usr/local/lib/python2.7/dist-packages/docker/models/nodes.py", line 106, in list
    for n in self.client.api.nodes(*args, **kwargs)
  File "/usr/local/lib/python2.7/dist-packages/docker/utils/decorators.py", line 34, in wrapper
    return f(self, *args, **kwargs)
  File "/usr/local/lib/python2.7/dist-packages/docker/api/swarm.py", line 256, in nodes
    return self._result(self._get(url, params=params), True)
  File "/usr/local/lib/python2.7/dist-packages/docker/api/client.py", line 228, in _result
    self._raise_for_status(response)
  File "/usr/local/lib/python2.7/dist-packages/docker/api/client.py", line 224, in _raise_for_status
    raise create_api_error_from_http_exception(e)
  File "/usr/local/lib/python2.7/dist-packages/docker/errors.py", line 31, in create_api_error_from_http_exception
    raise cls(e, response=response, explanation=explanation)
docker.errors.APIError: 503 Server Error: Service Unavailable ("This node is not a swarm manager. Use "docker swarm init" or "docker swarm join" to connect this node to swarm and try again.")
```





