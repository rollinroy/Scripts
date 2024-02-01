#! /usr/bin/env python3
# copy an activity log (e.g., create financial reports; backup data; etc) into
# activity log in google drive.
from       datetime import date
import     datetime
import     time
import     os
import     pprint
import     csv
import     copy
import     sys
import     json
import     shutil
import     socket
from       argparse import ArgumentParser

debug = False
msgErrPrefix='>>>>> Error - '
msgInfoPrefix='>>>>> Info - '
debugPrefix='>>>>> Debug - '

def pInfo(msg):
    tmsg=time.asctime()
    print(msgInfoPrefix+tmsg+": "+msg)
    sys.stdout.flush()

def ppInfo(msg,ppData):
    print(msgInfoPrefix+msg)
    pprint.pprint(ppData)

def pError(msg):
    tmsg=time.asctime()
    print(msgErrPrefix+tmsg+"\nERROR:\t"+msg)
    sys.stdout.flush()

def pDebug(msg):
    if debug:
        tmsg=time.asctime()
        print(debugPrefix+tmsg+": "+msg)
        sys.stdout.flush()

def ppDebug(msg,ppData):
    if debug:
        print(debugPrefix+msg)
        pprint.pprint(ppData)


def CopyLog(logFile, destDir):
    pInfo("Copying " + os.path.basename(logFile) + " to: " + destDir)
    shutil.copy2(logFile, destDir)

defLogDest = '/Users/royboy/Google Drive/My Drive/ActivityLogs'
actLogFiles = ["/tmp/mongodb_reports.log",
               "/tmp/backup_mongodb.log",
               "/tmp/rsync_work.log",
               "/tmp/rsync_scratch.log",
               "/tmp/rsync_data.log"]
parser = ArgumentParser( description = "Copy the activity log files to google drive ..." )
parser.add_argument( "-d", "--dest", default = defLogDest,
                     help = "destination folder for copying log file [default: " + defLogDest + "]" )
parser.add_argument( "-D", "--Debug", action="store_true", default = False,
                     help = "Turn on debug output [default: False]" )
parser.add_argument( "--version", action="store_true", default = False,
                     help = "Print version of " + __file__ )
args = parser.parse_args()
debug = args.Debug
destFolder = args.dest

for logFile in actLogFiles:
    # check files exists
    if not os.path.isfile(logFile):
        pError('Log file ' + logFile + ' does not exist; no copy')
        sys.exit(1)
    if not os.path.isdir(destFolder):
        pError('Destination copy folder ' + destFolder + ' does not exist; no copy')
        sys.exit(1)

    CopyLog(logFile, destFolder)
