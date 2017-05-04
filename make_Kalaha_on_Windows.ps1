<# Frank Zhao, April 2013
 # Renames player module to folder name
 #
 # To run:
 # 1. Make sure Windows is happy by running 
 #    "Set-ExecutionPolicy Unrestricted" in Powershell once.
 # 2. Make sure this file is in your "Assignment 2 student template"
 #    directory.
 # 3. Either execute ./make_Kalaha_Windows.ps1 in Powershell
 #    or Right click -> Run in Powershell
 #>
Function renamePlayers {
    cd .\Sources\Opponents
    # echo "Checking directories..."
    $dirs = dir $path -Recurse | Where { $_.psIsContainer -eq $true }
    Foreach ($dir In $dirs) {
        $playername = $dir.name + "_"
        # Search for .hs files, one level deep
        $files = Get-ChildItem -Path $dir.fullname -Filter *.hs
        
        Foreach ($file In $files) {
          # Check the file exists
          If ($file) {
            # echo "Renaming..."
            (Get-Content $dir\$file) | 
              Foreach-Object {$_ -replace "module Opponents.*.Player", "module Opponents.$dir.Player"} | 
              Set-Content $dir\$file
          }
        }
  }
  cd ..\..
}

renamePlayers
echo "Renaming complete, compiling..."
ghc --make -rtsopts -with-rtsopts="-s" -dno-debug-output -O2 -Wall Sources/Kalaha.hs -fforce-recomp -iSources -odir "build" -hidir "build" -o Kalaha
# echo "Finished!"
