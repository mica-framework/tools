# ================================================
# Welcome to the MiCA Framework - TCP-Log-Analyzer
# MiCA = Microservice-based Simulation of Cyber Attacks
# --
# This TCP Log Analyzer provides the ability to track the a tcp-dump of a docker
# container and sends information about processed communication tasks to the MiCA Server.
# This provides the ability to be able to mark all processed network traffic of the
# processed attack, to the already logged network traffic.
# --
#
# Developed By
# Andreas Zinkl
# E-Mail: zinklandi@gmail.com
# ================================================
import subprocess as sub
import requests
import os
import socket
import argparse
import time
import sys
import psutil
import datetime


class TCPDumpDecoder:

    @staticmethod
    def _decode_arp(fields):
        return {
            'date': str(datetime.datetime.now().date()),
            'timestamp': fields[0],
            'protocol': fields[1],
            'message': [(str(field)) for field in fields[2:]]
        }

    @staticmethod
    def _decode_ip(fields):
        message = '|'.join(fields) # concat the fields by a pipe
        return {
            'date': str(datetime.datetime.now().date()),
            'timestamp': fields[0],
            'protocol': fields[1],
            'from': fields[2],
            'to': fields[4],
            'message': '{}'.format(message)
        }

    @staticmethod
    def decode(tcp_dump_str):

        # don't use ack packages for now
        if ' ack ' in tcp_dump_str:
            return None

        # split up to fields, to get the protocol which was used
        fields = tcp_dump_str.split(' ')
        protocol = fields[1]

        # now decode the 
        if protocol == "IP":
            return TCPDumpDecoder._decode_ip(fields)

        if protocol == "IP6":
            return TCPDumpDecoder._decode_ip(fields)

        if protocol == "ARP": 
            return TCPDumpDecoder._decode_arp(fields)

        return None


class TCPLogger:
    def __init__(self):
        self._log_storage = []
        self._host = os.environ['HOSTNAME']
        if self._host is None or self._host == "":
            self._host = socket.gethostname()
        self._backend = "http://192.168.123.101/api/v1"
        self._log_storage = '/tmp/tcpdump.log'
        self._attack_name_process = "startup"

    def send_log(self):
        print('>> Start sending the logged data to the backend..')

        # first check if the log file is created, if not we don't have any logs
        if not os.path.exists(self._log_storage):
            print("### Error! No Log-File ({}) exists! Check that you listened before!".format(self._log_storage))
            return

        # now just decode the dump and finally save it
        data = []
        log_file = open(self._log_storage, 'rb')
        log_file_data = log_file.readlines()
        for line in log_file_data:
            try:
                line = line.decode('utf-8')
            except Exception:
                pass
            line = line.split('\n')[0]
            line_dec = TCPDumpDecoder.decode(line)
            if line_dec:
                line_dec['hostname'] = self._host
                data.append(line_dec)
        log_file.close()

        # now check if we have some log data in here
        if len(data) > 0:
            # now send the package
            print("We have {} valid messages".format(len(data)))
            sub_package_size = 20
            print("We're going to send those with {} requests".format(int(len(data)/20)+1))
            start = 0
            end = sub_package_size

            while start < len(data):
                # split the sending data into requests with 10 entries per request
                sub_data = data[start:end]
                print("Sending sub-package with size {}".format(len(sub_data)))

                # send the data
                url = '{}/log'.format(self._backend, self._host)
                response = requests.post(url, json={'data': sub_data})

                # update the indizes
                start = end+1
                end = start + sub_package_size

        print('>> Finished Sending!')
        print('>> Cleaning up the log..')
        os.remove(self._log_storage)
        

    def print_logs(self):
        [print(log_line) for log_line in self._log_storage]

    def _se(self):
        processes = []
        return processes

    def _attack_is_running(self):

        # get the process list
        processes = []
        for proc in psutil.process_iter():
             # checking for startup.sh script means, that we're running the attack..
            if self._attack_name_process in proc.name().lower():
                return True
        
        # did not found the startup script
        return False

    def listen_traffic(self):

        # first check if the file exists, if not create it
        print('>> Running Pre-Checks on file {}'.format(self._log_storage))
        if not os.path.exists(self._log_storage):
            print('>> .. creating {} '.format(self._log_storage))
            open(self._log_storage, 'a').close()

        # start configure logging data
        print('>> Start Logging the TCPTraffic...')
        log_file = open(self._log_storage, 'a')

        # If we need additional information like ARP or IPv6 -> remove the 'ip' option!!
        print('>> Start listening..')
        proc = sub.Popen(['tcpdump', '-l', 'ip'], stdout=sub.PIPE)

        # start listening now
        listen = True
        while listen:

            # now save the current output to the log file
            line = proc.stdout.readline().decode('utf-8')
            log_file.write(line)

            # check if metasploit is still running, which means the attack is still going on
            if not self._attack_is_running():
                proc.terminate()
                print('>> Metasploit is not running anymore!')
                print('>> We are going to terminate the logging')
                listen = False
                break

        # close the file and send the logged data
        log_file.close()


if __name__ == '__main__':
 
    # get the arguments first
    parser = argparse.ArgumentParser(
        description='Listening to TCP Requests or send collected TCP Dumps to the MiCA Backend')
    parser.add_argument('-l', '--listen', action='store_true',
        help='Listens to the tcpdump and collects the data into /tmp/tcp-dump.txt')
    parser.add_argument('-s', '--send', action='store_true',
        help='Sends the /tmp/tcp-dump.txt log to the backend and deletes the log file afterwards')
    args = parser.parse_args()

    # wait 10 seconds till we start
    time.sleep(10)

    # now execute the required functionality
    log = TCPLogger()
    if args.listen:
        log.listen_traffic()
    elif args.send:
        log.send_log()
    else:
        print("No command is given! ... Please use -h or --help to get any help") # by default do nothing
