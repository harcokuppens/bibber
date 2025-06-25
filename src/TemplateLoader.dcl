definition module TemplateLoader

import System.FilePath
import System.Directory
import StringMap


// Main function: get all .template files from a folder into a map
loadTemplatesFromFolder :: FilePath *World -> (Bool, StringMap, *World)

getTemplateFiles :: FilePath *World -> (Bool, [FilePath], *World)