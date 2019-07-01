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

### Known issues

 - (multi-agent) when executing agent with "isLeader=True" and "leaderIP=", the address registered in `device-dynamic` is not correct.

## CHANGELOG

### 1.0.1 (28.06.19)

#### Changed

 - Fixes random failures during the execution of the hello-world (single-agent)

### 1.0 (26.06.19)

#### Added

 - First release running hello-world (single-agent) 





