# Extract Agent Package Contents

1. Copy this package to a target system

2. Extract the contents of the package tarball into a location your JVM can
access using the tar extraction utility. For example:

		$ tar -xvf Basic_Java_App_Agent_v2.tar

Note: the notional variable `AGENT_HOME` is a convention used throughout the
install instructions to refer to the `wily` directory under
where the Agent package was extracted. For example if
`Basic_Java_App_Agent_v2.tar` was extracted in `/opt/`, `AGENT_HOME`
value would be `/opt/wily`.

# Instrument any Java Application

1. Add this at the beginning of your JVM command line arguments:

        For Application using Java 8 and previous versions:

		 -javaagent:$AGENT_HOME/Agent.jar -DagentProfile=$AGENT_HOME/core/config/IntroscopeAgent.profile
        
        For Application using Java 9 and higher versions:

         -javaagent:$AGENT_HOME/Agent.jar -DagentProfile=$AGENT_HOME/core/config/IntroscopeAgent.profile --add-exports java.instrument/sun.instrument=ALL-UNNAMED --add-exports jdk.management/com.sun.management.internal=ALL-UNNAMED --patch-module java.base=$AGENT_HOME/common/AgentSocket.jar

2. Restart the JVM.

The install instructions and configuration instructions for extensions can also be found in the `installInstructions.md` file in the downloaded archive.
---
# Configuration
The `bundle.profile`, JSON file configured in bundle.profile, `IntroscopeAgent.profile` contains the configuration of the Automatic Attribute Decoration extension. Configure the required properties from ACC or in the configuration file.

The bundle.profile contains a below property to configure the JSON file name
## JSON file configuration
 It Specifies the path to the Attribute Decoration Extension Configuration File 
 
    attribute.decoration.jsonFileName.configuration=<JSON file name>


	
Json file configuration will have Environment Variables, System Variables, Static Attributes, Sentinel File, Application Attributes, Manifest File configuration as below.
 
## Environment Variables Configuration
If you add an environment variable configuration, your components from this agent will have that attribute added to the component as "env."+&lt;environment variable name&gt; with the current value of that environment variable available to the agent.

	"environmentProperties": ["JAVA_HOME","TEMP"]

## System Variables Configuration
If you add system variables, your components from this agent will have that attribute added to the component as "sys."+&lt;system property name&gt; with the current value of that system property available to the agent.

	"systemProperties": ["os.name","os.version"]

## Static Attribute Configuration
Any entry of the form {"attributeName":"name","value":"val"} will produce an attribute &lt;name&gt;=&lt;val&gt; with the prefix "usr."

 	"staticAttributeConfiguration":[{"attributeName":"name","value":"val"},{"attributeName":"name2","value":"val2"}]

## External File Configuration
You can specify external files to retrieve attributes from. They are dynamically reloaded. The example configuration is:

    "externalFileConfiguration":[{"fileName":"/attributes.txt","prefix":"file","delimiter":":","includePrefix":"","excludePrefix":"","includeSuffix":"","excludeSuffix":""}]
	

where:


- - `fileName` is the full path/ relative path from WILY_HOME/core/config/ folder to the file you want to read. The user under which the application server and the java process are running must have read permissions for that file. 
- `attribute prefix` will be added to the attributes that are read from the file.
- `delimiter` is "=" or ":" and will split name/value using this delimiter.
- `includePrefix` is a string which will eliminate all entries from the file that do not start with this value. Empty = all entries included.
- `excludePrefix` is a string which will eliminate all entries from this file that do start with this value. Empty = no entries excluded.
- `includeSuffix` is a string which will eliminate all entries from the file that do not end with this value. Empty = all entries included.
- `excludeSuffix` is a string which will eliminate all entries from the file that do end with this value. Empty = no entries excluded.


## Sentinel File Configuration
It specifies external files that indicate that an attribute should be set. It is dynamically reloaded. An example configuration is:

    "sentinelFileConfiguration":[{"attributeName":"sentinel-file","fileName":"/.sentinel.file","valueIfFound":"true","valueIfNotFound":"false","setValueIfNotFound":"false"}]

where
- `attributeName` is the name of the attribute to set.
- `fileName` is the file path/relative file path from WILY_HOME/core/config/ folder whose presence we want to detect.
- `valueIfFound` is the value of the attribute if the file is found.
- `valueIfNotFound` is the value of the attribute if the file is not found.
- `setValueIfNotFound` is used to suppress the attribute if the file is not found.

## Application Attributes Configuration
It specifies attributes to be added for given application Name. These attributes will be added to all called components of a given application name. It is dynamically reloaded. An example configuration is:
  
  	"applicationConfiguration":[{"applicationName":"sampleAppliction","attributeName":"sample","value":"test"}]

where
- `applicationName` is the name of the application.
- `attributeName` is the name of the attribute to set.
- `value` is the value of the attribute.
    

## Manifest File Configuration
This specifies the pathname of an application war file/relative file path from WILY_HOME/core/config/ folder that will contain web applications deployed on application server that an attribute should be set. It reads the application's war file and adds the attributes. These attributes contains information such as Implementation-Version, Build-Jdk, etc. An example configuration is:

    "manifestFileConfiguration":[{"applicationName":"sampleAppliction", "fileName":"/apache-tomcat-6.0.48/webapps/sampleApplication.war"}]
    

### Note
- These are JSON properties, file path doesn't allow single backward slash  '\\' , make sure to escape it as '\\\\'. Environment, System, Static, External,Sentinel attributes will be added in the APM Infrastructure Layer and Application, Manifest attributes will be added in the Application Layer.
- All JSON file properties are cold.
---
# muleesb (10.6.0.165)
# Mule Esb Monitoring

## Description
Mule ESB is a lightweight Java-based enterprise service bus (ESB) and integration platform that allows developers to connect applications together quickly and easily, enabling them to exchange data. Mule ESB enables easy integration of existing systems, regardless of the different technologies that the applications use, including JMS, Web Services, JDBC, HTTP, and more. The key advantage of an ESB is that it allows different applications to communicate with each other by acting as a transit system for carrying data between applications within your enterprise or across the Internet.

# Installation Instructions
Mule extension is part of the default agent installer, no additional steps are needed.
## Usage Instructions
The Mule ESB is structured into three main areas driven by defined "Flow" The monitoring solution extension provides visibility into the Transport Layer, Integration Layer and Application Layer visualizing the invocation elements by individual Flows.

          
### Inbound HTTP Traffic

* HTTP Endpoint ( Mule 3.6 and higher) : 
 The monitoring solution aligns with the standard CA APM features and visualizes inbound HTTP traffic via SOAP or Restful Web Services in the Frontend node in the investigator. The Apps metric path item is replaced with the name 
 or identification of the deployed Mule ESB application. The URI section, if not configured different (configuration section) is formatted with the defined URI of the HTTP Listener configuration. 
 'Frontends|Apps|{mule-application-name}' and 
 'Frontends|Apps|{mule-application-name}|URLs|{URI defined in Mule HTTP Listener}'
  		  	
* Mule ESB 3.3.0 HTTP Message Receiver Support : 
  The usage of the deprecated older HTTP Message Receiver is still supported. Metrics are visualized different on this HTTP Message Receiver component. The App node in the metric path is replaced by the receiver name and the URLs path with the 
  initial HTTP listening flow name.
 'Frontends|Apps|{mule-http-receiver-name}' and 
 'Frontends|Apps|{mule-http-receiver-name}|URLs|{mule-flow-name}'
 
* CXF Inbound Web Services : 
  In addition to the inbound http frontend metrics, the mule esb extension also visualizes inbound Web Services calls under the Web Services node in the Investigator. The first part of the custom metric path contains the http request path and the 
  second any available soap action.
  'Webservices|Server|{http-request-path}' and 
  'Webservices|Server|{http-request-path}|{soap-action}'
  		

### Outbound HTTP requests
 For outbound HTTP requests, the monitoring solution leverages the Backends node identical to all other CA APM solutions. HTTP calls are shown with the formatting 'Backends|WebService at {protocol}_//{host}_{port}|Paths|{path}' where the path component is being replaced by the path element of the request URI.In addition to the standard metrics, the Mule monitoring extension creates the metric Async Invocation Time (ms) metric. The Async Invocation Time is computed based on the async communication behaviour for outbound HTTP calls. By measuring the HTTP Response in the request flow, CA APM can measure the time to establish a request (Async Invocation Time) and the total round trip / request - response time for a request (Average Response Time).The Transaction Trace visualization also differs because of the async nature of the requests.		


### HTTP request payload visualization
As a special feature, the monitoring solution visualizes the HTTP payload of all inbound and outbound requests including the response payload. The payload is visualized in the transaction trace on the root component of the correspondent process sending or receiving the call.Besides HTTP traffic monitoring, this solution provides inbound and outbound message processing coverage for all defined endpoints in the Mule Flow. 
   

### Flow Visualization

Flows are the main transactional processes inside the Mule ESB framework. The monitoring solution has a special coverage for Flows with additional metrics making it easier to understand the requests and showing detailed error and analysis 
information.Flows are visualized at the Mule|Flows node.

Flow usage Metrics : 
'Mule|Flows:Active Flow Instances'	- The number of active flow instances. Instances are usually active while in listening mode.
'Mule|Flows:Average Branch Processing Time (ms)' - The average total time spent on the flow for processing. 
'Mule|Flows:Branch Processings Per Interval' -	The number of branches processed for this flow per interval.
---
# Browser Agent Configuration

The shell script BAConfig.sh version does the following actions:

1. Updates the snippet code in App Experience Analytics format and creates tenant ID and app ID.
2. Extracts the Browser Agent extension into wily/extensions/browser-agent-ext-&lt;version&gt;.
3. Updates the agent wily/extensions/Extensions.profile file property to turn on the Browser Agent.

Usage: ./BAConfig.sh username applicationname agenthomedir

Follow these steps:

1. Download the Java agent bundle.
2. Extract the bundle into the application server home, for example, /opt/apache-tomcat-9.0.0.M21
3. Locate the BAConfig.sh script inside the 'wily' folder.
4. Run the BAConfig.sh script. Use the following inputs for the script:
   - Your user name
   - The name that you want to use for the web application
   - The Agent home directory, for example, /opt/apache-tomcat-9.0.0.M21
5. Start the application server.

Note: You can run the script at anytime later, but you must restart the agent after you run the script.

Full details for configuring the Browser Agent can be found
[[here](https://docops.ca.com/ca-application-performance-management-digital-experience-insights-from-ca/ga/en/implementing-agents/java-agent/configure-the-browser-agent/browser-agent-advanced-configuration)].
---
# springasync (10.6.0.165)

# Spring Async Monitoring
This extension fully supports all types of Spring Async operations displaying details like metrics, correlation and Team Center support.
* Whenever a new Async Thread request is initiated, the Investigator in Introscope shows the initiation as a metric under Spring node with the name "Async Task Execution" in combination with the corresponding threading mechanism used by the application.
  * Metric "Spring|Async Task Execution|{classname}"
* The Thread which was initiated and is being executed visualizes its starting point as a Frontend Metric "Async-XYZ" while XYZ is replaced with the type of Thread execution used by the Framework
  * Metric "Frontend|Apps|Spring-Async|Default"
---
# springmongo (10.6.0.165)

# Spring Mongo DB Monitoring
* This is a monitoring solution for Spring MongoDB API requests with full support of request details towards the Mongo DB instance.
* Introscope shows the calls to the MongoDB at the Backend node starting with "Mongo DB on {host} at {port}". 
* Further details are discovered request type, the related object to the request and if available, the request criteria.
---
# springrabbitmq (10.6.0.165)

# Spring AMQP Rabbit MQ Monitoring
In addition to the core Introscope Agent capability of JMS monitoring, this monitoring extensions adds support for Spring AMQP based message handling for Rabbit MQ.
* Inbound Message Handling
  1. With the help of this extension,Introscope discovers inbound messages as request and transaction starting points.
  2. Introscope visualizes the inbound message and request start point as a Frontends|Messaging Services (onMessage)|Queue|{queue}.
* Outbound Message Handling
  1. Outbound messaging calls (Message Put) are shown at the Backends node in the Investigator.The Rabbit MQ and the detailed queue name for the outbound message.
  2. Metric "Backends|Messaging Services (outgoing)|Queue|{queue}".
---
# springboot (10.6.0.165)

# Spring Boot Monitoring
The extension is a monitoring solution to provide extended visibility into Spring - Boot applications.

# Spring Boot Application Discovery
* The monitoring solution discovers requests to the Spring Boot Application by creating a Frontend metric in the Investigator using the classname of the Spring Boot Application definition.
* The correct Frontend name is used in the metric visualization as well as Transaction Traces and Team Center.
---
# Other Bundle: Instrument any Java Application

1. Add this at the beginning of your JVM command line arguments:

		-javaagent:$AGENT_HOME/Agent.jar -DagentProfile=$AGENT_HOME/core/config/IntroscopeAgent.profile

2. Restart the JVM.