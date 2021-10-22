import sys, os, signal

def process(prog, name):

    # Ask user for the name of process
    # name = input("Enter process Name: ")
    print("%s try to kill Process %s" % (prog, name))
    try:

        # iterating through each instance of the process
        for line in os.popen("ps ax | grep " + name + " | grep -v grep | grep -v " + prog):
            # print("%s" % str(line))
            fields = line.split()

            # extracting Process ID from the output
            pid = fields[0]

            # terminating process
            os.kill(int(pid), signal.SIGKILL)
            print("Process Successfully terminated")

    except:
        print("Error Encountered while running script")

total = len(sys.argv)
# cmdargs = str(sys.argv)
# print ("The total numbers of args passed to the script: %d " % total)
# print ("Args list: %s " % cmdargs)
# Pharsing args one by one
for i in range(1, total):
    n=str(sys.argv[i])
    # print ("%d Script name: %s" % (i, n))
    process(str(sys.argv[0]), n)
