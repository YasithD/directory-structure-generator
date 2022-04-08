import ballerina/io;
import ballerina/file;

// command line input: relative path of the folder structure
configurable string inputPath = ?;

// absolute path of the program
string base = check file:getAbsolutePath("./");

type Folder record {|
    string dirName;
    int level;
    boolean isDir;
    Folder[] subDirectories?;
|};

public function generateStructure(string path, int level=0) returns Folder|error {
    boolean isDir = check file:test(path, file:IS_DIR);
    string[] splitted = check file:splitPath(path);
    string dirName = splitted[splitted.length()-1];

    if !isDir {
        Folder file = { dirName, level, isDir };
        return file;
    }

    file:MetaData[] subDir = check file:readDir(path);
    Folder[] subDirectories = [];
    foreach file:MetaData dir in subDir {
        string absPath = dir.absPath;
        string relPath = check file:relativePath(base, absPath);
        Folder folder = check generateStructure(relPath, level+1);
        subDirectories.push(folder);
    }

    Folder dirStructure = { dirName, level, isDir, subDirectories };
    return dirStructure;
}

public function main() returns error? {
    Folder dirStructure = check generateStructure(inputPath);
    json jsonDirStructure = <json> dirStructure;

    check io:fileWriteJson("./files.json", jsonDirStructure);
}