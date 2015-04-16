# OpenAperture.OverseerApi

This reusable Elixir messaging library provides an application for interacting with the Overseer system module.  It provides the following features:

* Provides a Publisher to send events to the Overseer associated with the exchange
* Provides a ModuleRegistration module which will register your module with OpenAperture on startup
* Provides a Heartbeat GenServer which will update the Overseer every 30 seconds with a status update.

## Usage

Add the :openaperture_overseer_api application to your Elixir application or module.

### Heartbeat

The Heartbeat GenServer can also push the current workload to OpenAperture which can be used to determine overall system health.  You can simply call set_workload, passing in a list to set the current activity.  Each entry in the list should have a "description" property that can be used for human-readable displays.  Other information may be send as well.

```iex
OpenAperture.OverseerApi.Heartbeat.set_workload([%{
	"description": "building workflow 123"
	}
])
```

## Module Configuration

The following configuration values must be defined as part of your application's environment configuration files:

* Current Exchange
	* Type:  String
	* Description:  The identifier of the exchange in which the Overseer is running
  * Environment Configuration (.exs): :openaperture_overseer_api, :exchange_id  
* Current Broker
	* Type:  String
	* Description:  The identifier of the broker to which the Overseer is connecting
  * Environment Configuration (.exs): :openaperture_overseer_api, :broker_id
* System Module Type
	* Type:  atom or string
	* Description:  An atom or string describing what kind of system module is running (i.e. builder, deployer, etc...)
  * Environment Configuration (.exs): :openaperture_overseer_api, :module_type

This module also depends on [Messaging](https://github.com/OpenAperture/messaging) and [ManagerApi](https://github.com/OpenAperture/manager_api), so those configuration values must be present as well.

## Building & Testing

The normal elixir project setup steps are required:

```iex
mix do deps.get, deps.compile
```

You can then run the tests

```iex
MIX_ENV=test mix test test/
```
