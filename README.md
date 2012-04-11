# Skebby SMS gateway

This software permits to send free SMS with the Skebby.it service using the command line

## Usage

Sign-up to the [Skebby website](http://www.skebby.it) and set a username and a password.
Put them in the script and set sender and recipient.
Send SMS from CLI using this syntax:

    ./gateway.rb "My awesome message"
    
## Nagios/Icinga

The main purpose of the script is to send Nagios/Icinga alert messages when a host or a service goes down.
You can define two new commands:

    # 'notify-service-by-sms' command definition
    define command{
          command_name    notify-service-by-sms
          command_line      /usr/local/icinga/libexec/sms_gateway "--Nagios Service Notification-- Host: $HOSTNAME$, State: $HOSTSTATE$ Service $SERVICEDESC$ Description: $SERVICESTATE$ Time: $LONGDATETIME$"
    }
    # 'notify-host-by-sms' command definition
    define command{
          command_name    notify-host-by-sms
          command_line      /usr/local/icinga/libexec/sms_gateway "--Nagios Host Notification-- Host: $HOSTNAME$, State: $HOSTSTATE$, Time: $LONGDATETIME$"
    }
    
and use them when hosts or services have problems:

    define contact{
        contact_name                    icingaadmin
        use                             generic-contact
        alias                           Icinga Admin
        email                           my_email@domain.com
        host_notification_commands      notify-host-by-sms,notify-host-by-email
        service_notification_commands   notify-service-by-sms,notify-service-by-email
    }

An italian guide is on my blog: http://www.tommyblue.it/2012/01/18/notifiche-sms-gratis-con-nagiosicinga-e-skebby/
