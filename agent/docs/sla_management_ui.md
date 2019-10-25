# SLA Management UI

The SLA Management UI is a dashboard that shows the status of mF2C SLAs.

## Usage

(Work in progress)

Browse to https://<agent>/sla

### Troubleshooting

* If nothing is shown, check in the console if there is any error.
* Check the Network tab of your console. If requests to /api return 200, maybe
  you just need to populate CIMI. Run `hello-world` script.

## CHANGELOG

### v0.1.3 - 2019-10-15

#### Changed

* Changed nginx config: root of SLA UI is /sla instead of /sla/

### v0.1.2 - 2019-10-14

#### Added

* First functional version. Just shows service-instances and violations per service-instance.

