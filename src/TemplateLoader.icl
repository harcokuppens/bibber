implementation module TemplateLoader

import StdEnv

import StdMaybe
import System.Directory
import System.FilePath
import System.File
import StringMap

import qualified System.File as sysfile

import Data.Error

//import Chaining

import CustomDebug

// Main function to load templates from a folder
loadTemplatesFromFolder :: FilePath *World -> (Bool, StringMap, *World)
loadTemplatesFromFolder folder world
    # (ok, files, world) = getTemplateFiles folder world
    | not ok = (False, [], world)
    # (map, world) = loadTemplates files [] world
    = (True, map, world)

filterWithWorld :: (a *World -> (Bool, *World)) [a] *World -> ([a], *World)
filterWithWorld f [] world = ([], world)
filterWithWorld f [x:xs] world
    # (keep, world) = f x world
    # (rest, world) = filterWithWorld f xs world
    | keep
        = ([x:rest], world)
    | otherwise
        = (rest, world)


// Function to get template files from the folder
getTemplateFiles :: FilePath *World -> (Bool, [FilePath], *World)
getTemplateFiles folder world
    # (result, world) = readDirectory folder world
    = case result of
        Ok entries
            # folderEntries = [ folder +++  toString pathSeparator +++ e  \\ e <- entries ]
            # (templateFiles, world) = filterWithWorld isTemplate folderEntries world
            = (True, templateFiles, world)
        _ = (False, [], world)


isDirectory :: FilePath  *World  -> (Bool,*World)
isDirectory e world
  # (maybeerror,world) = getFileInfo e world
  | isError maybeerror
      = (False,world)
  # fileinfo = fromOk maybeerror
  = (fileinfo.directory,world)

isExistingDirectory :: FilePath *World  -> (Bool,*World)
isExistingDirectory e world
    # (exist, world) = fileExists e world
    | exist
       = isDirectory e world
    | otherwise
       = (False, world)

isExistingFile :: FilePath *World  -> (Bool,*World)
isExistingFile e world
    # (exist, world) = fileExists e world
    | exist
        # (isDir, world) = isDirectory e world
        = ( not isDir, world )
    | otherwise
       = (False, world)

// Helper function to check if a file is a template
isTemplate :: FilePath *World -> (Bool,*World)
isTemplate e world
    # (exist, world) = isExistingFile e world
    | False
        = undef
    | exist
       =  ( (fileExtension e == "template") , world )
    | otherwise
       = (False, world)


// Function to load templates into a map
loadTemplates :: [FilePath] StringMap *World -> (StringMap, *World)
loadTemplates [] map world = (map, world)
loadTemplates [f:fs] map world
    # (maybeerror, world) = 'sysfile'.readFile f world
    //# (maybeerror, world) = readFile f world
    | isError maybeerror
        = abort ("Failed to read: " +++ f)
    # content = fromOk maybeerror
    //# key = (dropExtension o takeFileName) f
    # key = dropExtension ( takeFileName f )
    // # key = dropExtension $ takeFileName f // $ is low precedence function application (like in haskell)
    # map = insertPair key content map
    = loadTemplates fs map world


// // Return a default value if the result is Nothing
// fromMaybe :: a (Maybe a) -> a
// fromMaybe def Nothing  = def
// fromMaybe _   (Just x) = x

// Get the file extension from a file path
fileExtension :: FilePath -> String
fileExtension path = snd (splitExtension path)