﻿$packageName    = 'irfanview'
$installerType  = 'exe'
$toolsDir       = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"
$url            = "$toolsDir\iview451_setup.exe"
$checksum       = '0A5400988954EC933EDAC01B8822F9937BB0B6BF2B1337B69CB3347BCA375DB2'
$checksumType   = 'sha256'
$url64          = "$toolsDir\iview451_x64_setup.exe"
$checksum64     = 'C4CAC895DBC4A3C31565C3947D48949A7EB611696C1D4FDE0161710C35460E6C'
$checksumType64 = 'sha256'
$validExitCodes = @(0)
$arguments      = @{}
$packageParameters = $env:chocolateyPackageParameters

Write-Debug "Default values for package parameters: 0=off, 1=on"
$desktop = 0
$thumbs = 0
$group = 1
$allusers = 1
$assoc = 1
$ini = "%APPDATA%\IrfanView"
$folder = $null

if ($packageParameters) {
    $match_pattern = "\/(?<option>([a-zA-Z]+))=(?<value>([`"'])?([a-zA-Z0-9- _\\:%\.]+)([`"'])?)|\/(?<option>([a-zA-Z]+))"
    $option_name = 'option'
    $value_name = 'value'

    if ($packageParameters -match $match_pattern ){
        $results = $packageParameters | Select-String $match_pattern -AllMatches
        $results.matches | ForEach-Object {
          $arguments.Add(
              $_.Groups[$option_name].Value.Trim(),
              $_.Groups[$value_name].Value.Trim())
      }
    } else {
        Throw "Package Parameters were found but were invalid (REGEX failure)"
    }

    if ($arguments.ContainsKey("desktop")) {
        Write-Verbose "Adding desktop shortcut to IrfanView"
        $desktop = 1
    }

    if ($arguments.ContainsKey("thumbs")) {
        Write-Verbose "Adding desktop shortcut to IrfanView Thumbnails"
        $thumbs = 1
    }

    if ($arguments.ContainsKey("group")) {
        Write-Verbose "Adding IrfanView group to start menu"
        $group = 1
    }
    
    if ($arguments.ContainsKey("allusers")) {
        Write-Verbose "Installing IrfanView for only current user"
        $allusers = 0
    }
    
    if ($arguments.ContainsKey("assoc")) {
        Write-Verbose "Associating IrfanView to file types"
        $assoc = $arguments["assoc"]
    }

    if ($arguments.ContainsKey("ini")) {
        Write-Verbose "You want to use a custom configuration Path"
        $ini = $arguments["ini"]
    }
    
    if ($arguments.ContainsKey("folder")) {
        Write-Verbose "You want to use a custom configuration Path"
        $folder = $arguments["folder"]
    }

} else {
    Write-Debug "No package parameters passed in"
}

$silentArgs = "/silent" + 
              " /desktop=" + $desktop + 
              " /thumbs=" + $thumbs + 
              " /group=" + $group + 
              " /allusers=" + $allusers +
              " /assoc=" + $assoc
if ($ini) { $silentArgs += " /ini=" + $ini }
if ($folder) { $silentArgs += " /folder=" + $folder }
Write-Debug "Silent arguments Chocolatey will use are: $silentArgs"

$packageArgs = @{
  packageName   = $packageName
  fileType      = $installerType
  url           = $url
  url64bit      = $url64
  validExitCodes= $validExitCodes
  silentArgs    = $silentArgs
  softwareName  = 'IrfanView*'
  checksum      = $checksum
  checksumType  = $checksumType
  Checksum64    = $checksum64
  ChecksumType64= $checksumType64
}

Install-ChocolateyPackage @packageArgs 	

Remove-Item $url | out-null
Remove-Item $url64 | out-null