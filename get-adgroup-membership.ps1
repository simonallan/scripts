# Simple script to get membership of all AWS Landing Zone AD groups

Import-Module ActiveDirectory

# Use naming convention to get LZ specific AD groups
$lzadgroups=Get-ADGroup -Filter {name -like "ar - aws*"} | select samaccountname | sort Name

ForEach ($g in $lzadgroups.samaccountname){
  Write-host $g
    Foreach ($m in $g){
      Get-ADGroupMember $m | select name
      }
  Write-host ""
  }
