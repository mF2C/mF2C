# CIMI

The mF2C system is equipped with a RESTful (HTTP) API for the management of infrastructure resources. This API is based on the Cloud Infrastructure Management Interface (CIMI) specification from DMTF.



The mF2C API implementation has been adopted from the open source implementation used in Nuvla (https://nuv.la).


## Usage

### API

The CIMI standard defined patterns for all the usual database actions: Search (or Query), Create, Read, Update, and Delete (SCRUD).


| Action        |  HTTP Method  |  Target    |
|------	|------	|--------	|
| Search        | GET or PUT  | resource collection |
| Add (create)  | POST        | resource collection |
| Read          | GET         | resource            |
| Edit (update) | PUT         | resource            |
| Delete        | DELETE      | resource            |

And the endpoint grammar follows the following convention:

`/api/<resource_name>/<uuid>?<queries>`


#### Examples

##### User

 - create a regular user *testuser* with password *testpassword*

```
POST /api/user
```
--
```
DATA:
    {
        "userTemplate": {
            "href": "user-template/self-registration",
            "password": "testpassword",
            "passwordRepeat" : "testpassword",
            "emailAddress": "your_email@",
            "username": "testuser"
        }
    }
```

-  login

```
POST /api/session
```
--
```
DATA:
    {
        "sessionTemplate": {
            "href": "session-template/internal",
            "username": "testuser",
            "password": "testpassword"
        }
    }
```


##### Get an existing resource collection

```
GET /api/event
```

##### Filter for a specific dataset

```
GET /api/event?$filter=<AttrName>="<Value>"&$filter=<AttrName2><=<Value2>&$orderby=<AttrName3>:desc
```

##### Delete a specific resource

```
DELETE /api/event/<uuid>
```



### Troubleshooting




## CHANGELOG

### 2.18 (17/05/2019)

#### Added

#### Changed

 - added status to device resource


### 2.16 (17/05/2019)

#### Added

#### Changed

 - resource schemas for `service` and `service_instance`, to include recommended resource requirements





