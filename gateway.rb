#!/usr/bin/env ruby
# Copyright 2012 by Tommaso Visconti <tommaso.visconti@gmail.com>
#
# This software permits to send free SMS using the Skebby.it service using the command line
# @author Tommaso Visconti<tommaso.visconti@gmail.com>
#
#  This program is free software: you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation, either version 3 of the License, or
#  (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with this program.  If not, see <http://www.gnu.org/licenses/>.

require 'net/http'
require 'uri'
require 'cgi'

# Configure these params
#
# Sender and recipient must have international prefix, but only 2 digits withou 00 or + at the beginning.
# e.g. +39.333.1234567 must be written 393331234567
$SENDER = '393337654321'
$RECIPIENT = '393331234567'
$USERNAME = 'skebby_username'
$PASSWORD = 'skebby_password'

# The class sends free SMS using the Skebby API
class SkebbyGatewaySendSMS

	# Initializes the object
	# @param username [String] The Skebby username
	# @param text [String] The text of the SMS
	# @param recipients [Array] The recipients of the message
	# @param sender [String] The SMS sender
	def initialize(username = '', text = '', recipient = '', sender = '')

		@url = 'http://gateway.skebby.it/api/send/smsskebby/advanced/http.php'
		
		sms_method = 'send_sms'
		
		#@recipients = getRecipients(recipients)		

		@parameters = {
			'method'		=> sms_method,
			'username'		=> username,
			'password'		=> self.getPassword,
			'text'			=> text,
			'recipients[]'	=> recipient,
			'sender_number'	=> sender
		}
	end

	# Sends the HTTP request
	# @return [Boolean] The result of the HTTP request
	# @note It returns the result of the HTTP request, not the result of the sending. Use getResponse() or printResponse() to check that!
	def sendSMS
		@response = Net::HTTP.post_form(URI(@url), @parameters)

		if @response.message == "OK"
			true
		else
			false
		end
	end

	# Return the response from the server
	# @return [Hash] The hash containing the result of the sending
	def getResponse
		result = {}
		@response.body.split('&').each do |res|
			if res != ''
				temp = res.split('=')
				if temp.size > 1
					result[temp[0]] = temp[1]
				end
			end
		end
				
		return result
	end

	# Prints the response in human-readable format
	# @return [Boolean] The result of the SMS sending
	def printResponse
		result = self.getResponse
		if result.has_key?('status') and result['status'] == 'success'
			puts "SMS sent successfully"
			true
		else
			puts "Error sending the SMS, printing the full trace:"
			result.each do |key,value|
				puts "\t#{key} => #{CGI::unescape(value)}"
			end
			false
		end
	end

	# Encodes the recipients in the correct format
	# @param recipients [Array] The Array containing the recipients as String in the format 3912345678 (without + or 00 at the beginning)
	# @return [String] The String in the format accepted by the server
	# @note This method uses CGI::escape to escape the recipients
	def getRecipients(recipients)
		recipients.inject('') do |result, number|
			result << '&' unless number == recipients.first
			result << "recipients[]=#{CGI::escape(number)}"
		end
	end

	# Obtains the password from the command line hiding the input
	# @return (String) The given password
	def getPassword
		unless $PASSWORD.nil?
			password = $PASSWORD
		else
			puts "Password:"
			system "stty -echo"
			password = $stdin.gets.chomp
			system "stty echo"
		end
		password
	end
end

# Example method to send SMS fast
def send_my_sms(text = 'Empty')
	gw = SkebbyGatewaySendSMS.new($USERNAME, text, $RECIPIENT, $SENDER)
	
	if gw.sendSMS
		gw.printResponse
	else
		puts "Error in the HTTP request"
	end
end

# Send SMS with Icinga/Nagios
if ARGV.size > 0
	text = ARGV[0]
	send_my_sms(text)
end
