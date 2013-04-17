# Maze reformatter for mazes made by th associated Ruby script.
# Author: Perry Shuman

import argparse

parser = argparse.ArgumentParser()
parser.add_argument("fileName", help="The file to be edited")
args = parser.parse_args()

def main():
    maze = open(args.fileName, "r+")
    cut = ""
    
    for line in maze:    
        cut += line[0:-1:2] + "\n"
    
    maze.seek(0)
    maze.write(cut)
    maze.truncate()
    maze.close()
    


if __name__ == "__main__":
    main()