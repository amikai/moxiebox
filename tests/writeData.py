newFileBytes = [0xA]
# make file
newFile = open("data", "wb")
# write to file
for byte in newFileBytes:
    print("write")
    newFile.write(byte.to_bytes(4, byteorder='little'))
