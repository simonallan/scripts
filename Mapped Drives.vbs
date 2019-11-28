' The login script maps network drives according to AD group membership - It will overwrite existing 
' drive mappings with the same letter
' The login script then displays a message window listing all network drive mappings on the users workstation
' The message window disappears automatically after 5 seconds
' The drive mappings present on users workstations are written out to a log file named after the users login ID in \\venus\loginscriptlogs$
' Any log files older than 10 days are deleted.
' The users workstation IP address is added to the log file
' The users username, IP address, computername and a timestamp are written to a SQL Server database table [UK-LIF-LSQL06\SYSTEMS].SystemsDB.LoginLog

On Error Resume Next
' Declare Variables
Dim objRootDSE, objTrans, strNetBIOSDomain, objNetwork, strNTName
Dim strUserDN, strComputerDN, objGroupList, objUser, strDNSDomain
Dim strComputer, objComputer, objfso, objfilecreate, objfilewrite
Dim strHomeDrive, strHomeShare, thisday, isodate, sdirectorypath, ofolder, ofilecollection, ofile, idaysold
Dim objCommand, objConnection, strBase, strAttributes

dim path
' Expand userprofile path to var path
path=CreateObject("WScript.Shell").ExpandEnvironmentStrings("%UserProfile%")
'Set Dimension
'DIM objFSO
'Set Object
Set objFSO = CreateObject("Scripting.FileSystemObject")
'Check if the file exists at userprofile\filename.vbs if not continue if does stop
If objFSO.FileExists(path & ("\signature.vbs")) = False Then
' copy file to userprofile\filename.ext
objFSO.CopyFile "\\crwin.crnet.org\NETLOGON\signature.vbs", path & "\"
' run file at userprofile\signature.vbs
Set WshShell = WScript.CreateObject("WScript.Shell")
WshShell.Run(""""&path & "\signature.vbs""")
End if

' Constants for the NameTranslate object.
Const ADS_NAME_INITTYPE_GC = 3
Const ADS_NAME_TYPE_NT4 = 3
Const ADS_NAME_TYPE_1779 = 1

' Create a WSH Network object and bind the objnetwork variable to it
Set objNetwork = CreateObject("Wscript.Network")

' Assign the users network userid to the strNTName variable
strNTName = objNetwork.UserName

' Determine DNS domain name from RootDSE object.
Set objRootDSE = GetObject("LDAP://RootDSE")
strDNSDomain = objRootDSE.Get("defaultNamingContext")

' Use the NameTranslate object to find the NetBIOS domain name from the
' DNS domain name.
Set objTrans = CreateObject("NameTranslate")
objTrans.Init ADS_NAME_INITTYPE_GC, ""
objTrans.Set ADS_NAME_TYPE_1779, strDNSDomain
strNetBIOSDomain = objTrans.Get(ADS_NAME_TYPE_NT4)
' Remove trailing backslash.
strNetBIOSDomain = Left(strNetBIOSDomain, Len(strNetBIOSDomain) - 1)

' Use the NameTranslate object to convert the NT user name to the
' Distinguished Name required for the LDAP provider.
objTrans.Set ADS_NAME_TYPE_NT4, strNetBIOSDomain & "\" & strNTName
strUserDN = objTrans.Get(ADS_NAME_TYPE_1779)

' Bind objshell variable WSH shell to allow exposure of the message window popup property
     Set objShell = CreateObject("Wscript.Shell")

' Bind to the user object in Active Directory with the LDAP provider.
Set objUser = GetObject("LDAP://" & strUserDN)

If Err.Number <> 0 Then
                DisplayMessage = objshell.popup ( "Error Running Logon Script - Please disconnect your VPN session and try again." & vbCRLF & vbCRLF & "This information box will automatically close after 15 seconds", 15, "Cancer Research UK.")
                wscript.quit
Else 
'                DisplayMessage = objshell.popup ( "Connection Successful" & vbCRLF & vbCRLF & "This information box will automatically close after 15 seconds", 15, "Cancer Research UK.")
                
End If


' Bind to the user object in Active Directory with the LDAP provider.
Set objUser = GetObject("LDAP://" & strUserDN)

' NETWORK DRIVE MAPPINGS BASED ON AD GROUP MEMBERSHIP

' Map a network drive letter to the UNC path if the user is a member of the group specified in IsMember(objUser, "AD GROUP NAME") 

If IsMember(objUser, "Citrix Raisers J Drive") Then
  On Error Resume Next
  objNetwork.MapNetworkDrive "J:", "\\crwin.crnet.org\dfs\bus\Rew_Shared"
If Err.Number <> 0 Then
    objNetwork.RemoveNetworkDrive "J:", True, True
    objNetwork.MapNetworkDrive "J:", "\\crwin.crnet.org\dfs\bus\Rew_Shared"
  End If
End If

If IsMember(objUser, "FS-HVR") Then
  On Error Resume Next
  objNetwork.MapNetworkDrive "G:", "\\CRWIN.CRNET.ORG\DFS\BUS\DEPT\HVR"
If Err.Number <> 0 Then
    objNetwork.RemoveNetworkDrive "G:", True, True
    objNetwork.MapNetworkDrive "G:", "\\CRWIN.CRNET.ORG\DFS\BUS\DEPT\HVR"
  End If
End If

If IsMember(objUser, "FS-HVR") Then
  On Error Resume Next
  objNetwork.MapNetworkDrive "K:", "\\CRWIN.CRNET.ORG\DFS\BUS\DEPT\HVR2"
If Err.Number <> 0 Then
    objNetwork.RemoveNetworkDrive "K:", True, True
    objNetwork.MapNetworkDrive "K:", "\\CRWIN.CRNET.ORG\DFS\BUS\DEPT\HVR2"
  End If
End If

If IsMember(objUser, "FS-SRM-Interface") Then
  On Error Resume Next
  objNetwork.MapNetworkDrive "S:", "\\crwin.crnet.org\dfs\bus\dept\srm\interface"
If Err.Number <> 0 Then
    objNetwork.RemoveNetworkDrive "S:", True, True
    objNetwork.MapNetworkDrive "S:", "\\crwin.crnet.org\dfs\bus\dept\srm\interface"
  End If
End If

If IsMember(objUser, "FS-Local-Supporter-Fundraising-Regional") Then
  On Error Resume Next
  objNetwork.MapNetworkDrive "R:", "\\crwin.crnet.org\dfs\bus\dept\lsf"
If Err.Number <> 0 Then
    objNetwork.RemoveNetworkDrive "R:", True, True
   objNetwork.MapNetworkDrive "R:", "\\crwin.crnet.org\dfs\bus\dept\lsf"
  End If
End If

If IsMember(objUser, "FS-FirstClass") Then
  On Error Resume Next
  objNetwork.MapNetworkDrive "N:", "\\uk-lif-lsql05\FirstClass\fclive"
If Err.Number <> 0 Then
    objNetwork.RemoveNetworkDrive "N:", True, True
   objNetwork.MapNetworkDrive "N:", "\\uk-lif-lsql05\FirstClass\fclive"
  End If
End If

If IsMember(objUser, "FS-IS-DEVELOPMENT") Then
  On Error Resume Next
  objNetwork.MapNetworkDrive "G:", "\\CRWIN.CRNET.ORG\DFS\BUS\DEPT\ISD\GROUPS"
If Err.Number <> 0 Then
    objNetwork.RemoveNetworkDrive "G:", True, True
   objNetwork.MapNetworkDrive "G:", "\\CRWIN.CRNET.ORG\DFS\BUS\DEPT\ISD\GROUPS"
  End If
End If

If IsMember(objUser, "FS-IS-INTRANET") Then
  On Error Resume Next
  objNetwork.MapNetworkDrive "G:", "\\CRWIN.CRNET.ORG\DFS\BUS\DEPT\ISD\GROUPS\INTRANET"
If Err.Number <> 0 Then
    objNetwork.RemoveNetworkDrive "G:", True, True
   objNetwork.MapNetworkDrive "G:", "\\CRWIN.CRNET.ORG\DFS\BUS\DEPT\ISD\GROUPS\INTRANET"
  End If
End If

If IsMember(objUser, "FS-APP-DATABASES") Then
  On Error Resume Next
  objNetwork.MapNetworkDrive "V:", "\\crwin.crnet.org\dfs\bus\applications\DATABASES"
If Err.Number <> 0 Then
    objNetwork.RemoveNetworkDrive "V:", True, True
   objNetwork.MapNetworkDrive "V:", "\\crwin.crnet.org\dfs\bus\applications\DATABASES"
  End If
End If

' Map a network drive letter to the UNC path if the user is a member of the group specified in IsMember(objUser, "AD GROUP NAME") 
If IsMember(objUser, "CRT Users") Then
  On Error Resume Next
  objNetwork.MapNetworkDrive "G:", "\\crwin.crnet.org\dfs\bus\dept\RI\CP\CP"
If Err.Number <> 0 Then
    objNetwork.RemoveNetworkDrive "G:", True, True
    objNetwork.MapNetworkDrive "G:", "\\crwin.crnet.org\dfs\bus\dept\RI\CP\CP"
  End If
End If

If IsMember(objUser, "FS-SECRETARIAT-Legal") Then
  On Error Resume Next
  objNetwork.MapNetworkDrive "F:", "\\crwin.crnet.org\dfs\bus\Data\CR-UK\EX\Legal\Legal"
If Err.Number <> 0 Then
    objNetwork.RemoveNetworkDrive "F:", True, True
   objNetwork.MapNetworkDrive "F:", "\\crwin.crnet.org\dfs\bus\Data\CR-UK\EX\Legal\Legal"
  End If
End If

If IsMember(objUser, "FS-RSM") Then
  On Error Resume Next
  objNetwork.MapNetworkDrive "F:", "\\crwin.crnet.org\dfs\bus\Data\CR-UK\RS\RSM"
If Err.Number <> 0 Then
    objNetwork.RemoveNetworkDrive "F:", True, True
    objNetwork.MapNetworkDrive "F:", "\\crwin.crnet.org\dfs\bus\Data\CR-UK\RS\RSM"
  End If
End If

If IsMember(objUser, "FS-CMAL Lab Staff") Then
  On Error Resume Next
  objNetwork.MapNetworkDrive "Q:", "\\crwin.crnet.org\dfs\bus\dept\CMAL"
If Err.Number <> 0 Then
    objNetwork.RemoveNetworkDrive "Q:", True, True
    objNetwork.MapNetworkDrive "Q:", "\\crwin.crnet.org\dfs\bus\dept\CMAL"
  End If
End If

If IsMember(objUser, "FS-CMAL Lab") Then
  On Error Resume Next
  objNetwork.MapNetworkDrive "S:", "\\crwin.crnet.org\dfs\bus\dept\CMAL LAB"
  If Err.Number <> 0 Then
    objNetwork.RemoveNetworkDrive "S:", True, True
    objNetwork.MapNetworkDrive "S:", "\\crwin.crnet.org\dfs\bus\dept\CMAL LAB"
  End If
End If


If IsMember(objUser, "FS-GRANTS") Then
  On Error Resume Next
  objNetwork.MapNetworkDrive "F:", "\\crwin.crnet.org\dfs\bus\Data\CR-UK\RS\GRANTS"
If Err.Number <> 0 Then
    objNetwork.RemoveNetworkDrive "F:", True, True
    objNetwork.MapNetworkDrive "F:", "\\crwin.crnet.org\dfs\bus\Data\CR-UK\RS\GRANTS"
  End If
End If

If IsMember(objUser, "FS-LIBRARY") Then
  On Error Resume Next
  objNetwork.MapNetworkDrive "F:", "\\crwin.crnet.org\dfs\bus\Data\CR-UK\RS\LIBRARY"
If Err.Number <> 0 Then
    objNetwork.RemoveNetworkDrive "F:", True, True
    objNetwork.MapNetworkDrive "F:", "\\crwin.crnet.org\dfs\bus\Data\CR-UK\RS\LIBRARY"
  End If
End If

If IsMember(objUser, "FS-COUNCIL") Then
  On Error Resume Next
  objNetwork.MapNetworkDrive "F:", "\\crwin.crnet.org\dfs\bus\Data\CR-UK\EX\COUNCIL"
If Err.Number <> 0 Then
    objNetwork.RemoveNetworkDrive "F:", True, True
    objNetwork.MapNetworkDrive "F:", "\\crwin.crnet.org\dfs\bus\Data\CR-UK\EX\COUNCIL"
  End If
End If

If IsMember(objUser, "FS-COUNCIL-Other") Then
  On Error Resume Next
  objNetwork.MapNetworkDrive "G:", "\\crwin.crnet.org\dfs\bus\Data\CR-UK\EX\COUNCIL"
If Err.Number <> 0 Then
    objNetwork.RemoveNetworkDrive "F:", True, True
    objNetwork.MapNetworkDrive "G:", "\\crwin.crnet.org\dfs\bus\Data\CR-UK\EX\COUNCIL"
  End If
End If

If IsMember(objUser, "Domain Users") Then
  On Error Resume Next
  objNetwork.MapNetworkDrive "W:", "\\crwin.crnet.org\dfs\bus\CROSS-DEPT-SHARES"
If Err.Number <> 0 Then
    objNetwork.RemoveNetworkDrive "W:", True, True
    objNetwork.MapNetworkDrive "W:", "\\crwin.crnet.org\dfs\bus\CROSS-DEPT-SHARES"
  End If
End If


If IsMember(objUser, "FS-APP-CLSERVER-LIF") Then
  On Error Resume Next
  objNetwork.MapNetworkDrive "T:", "\\crwin.crnet.org\dfs\bus\applications\APPS\CLSERVER"
If Err.Number <> 0 Then
    objNetwork.RemoveNetworkDrive "T:", True, True
    objNetwork.MapNetworkDrive "T:", "\\crwin.crnet.org\dfs\bus\applications\APPS\CLSERVER"
  End If
End If

If IsMember(objUser, "Domain Users") Then
  On Error Resume Next
  objNetwork.MapNetworkDrive "X:", "\\crwin.crnet.org\dfs\bus\GENERAL-SHARES"
If Err.Number <> 0 Then
    objNetwork.RemoveNetworkDrive "X:", True, True
    objNetwork.MapNetworkDrive "X:", "\\crwin.crnet.org\dfs\bus\GENERAL-SHARES"
  End If
End If


If IsMember(objUser, "FS-APPS") Then
  On Error Resume Next
  objNetwork.MapNetworkDrive "U:", "\\crwin.crnet.org\dfs\bus\applications\APPS"
If Err.Number <> 0 Then
    objNetwork.RemoveNetworkDrive "U:", True, True
    objNetwork.MapNetworkDrive "U:", "\\crwin.crnet.org\dfs\bus\applications\APPS"
  End If
End If


If IsMember(objUser, "FS-FUNDRAISING-DEVELOPMENT") Then
  On Error Resume Next
  objNetwork.MapNetworkDrive "F:", "\\CRWIN.CRNET.ORG\DFS\BUS\DEPT\FSM"
If Err.Number <> 0 Then
    objNetwork.RemoveNetworkDrive "F:", True, True
    objNetwork.MapNetworkDrive "F:", "\\CRWIN.CRNET.ORG\DFS\BUS\DEPT\FSM"
  End If
End If


If IsMember(objUser, "FS-FUNDRAISING-DEVELOPMENT-STORES") Then
  On Error Resume Next
  objNetwork.MapNetworkDrive "F:", "\\CRWIN.CRNET.ORG\DFS\BUS\DEPT\FSM\STORES"
If Err.Number <> 0 Then
    objNetwork.RemoveNetworkDrive "F:", True, True
    objNetwork.MapNetworkDrive "F:", "\\CRWIN.CRNET.ORG\DFS\BUS\DEPT\FSM\STORES"
  End If
End If



If IsMember(objUser, "FS-MARKETING-SUPPORTER-SERVICES-SECURE") Then
  On Error Resume Next
  objNetwork.MapNetworkDrive "G:", "\\crwin.crnet.org\DFS\BUS\DEPT\FM1\MARKETING\GROUPS"
If Err.Number <> 0 Then
    objNetwork.RemoveNetworkDrive "G:", True, True
    objNetwork.MapNetworkDrive "G:", "\\crwin.crnet.org\DFS\BUS\DEPT\FM1\MARKETING\GROUPS"
  End If
End If



If IsMember(objUser, "FS-MARKETING-SUPPORTER-SERVICES") Then
  On Error Resume Next
  objNetwork.MapNetworkDrive "G:", "\\crwin.crnet.org\DFS\BUS\DEPT\FM1\MARKETING\GROUPS"
If Err.Number <> 0 Then
    objNetwork.RemoveNetworkDrive "G:", True, True
    objNetwork.MapNetworkDrive "G:", "\\crwin.crnet.org\DFS\BUS\DEPT\FM1\MARKETING\GROUPS"
  End If
End If



If IsMember(objUser, "FS-MARKETING") Then
  On Error Resume Next
  objNetwork.MapNetworkDrive "G:", "\\crwin.crnet.org\DFS\BUS\DEPT\FM1\MARKETING\GROUPS"
If Err.Number <> 0 Then
    objNetwork.RemoveNetworkDrive "G:", True, True
    objNetwork.MapNetworkDrive "G:", "\\crwin.crnet.org\DFS\BUS\DEPT\FM1\MARKETING\GROUPS"
  End If
End If


If IsMember(objUser, "FS-MARKETING-MARKETING-SECURE") Then
  On Error Resume Next
  objNetwork.MapNetworkDrive "G:", "\\crwin.crnet.org\DFS\BUS\DEPT\FM1\MARKETING\GROUPS"
If Err.Number <> 0 Then
    objNetwork.RemoveNetworkDrive "G:", True, True
    objNetwork.MapNetworkDrive "G:", "\\crwin.crnet.org\DFS\BUS\DEPT\FM1\MARKETING\GROUPS"
  End If
End If


If IsMember(objUser, "FS-CRI-SHARED") Then
  On Error Resume Next
  objNetwork.MapNetworkDrive "L:", "\\UK-CRI-LFPS02\SHARED"
If Err.Number <> 0 Then
    objNetwork.RemoveNetworkDrive "L:", True, True
    objNetwork.MapNetworkDrive "L:", "\\UK-CRI-LFPS02\SHARED"
  End If
End If

If IsMember(objUser, "FS-MARKETING") Then
  On Error Resume Next
  objNetwork.MapNetworkDrive "F:", "\\crwin.crnet.org\DFS\BUS\DEPT\FM1\MARKETING\MARKETING"
If Err.Number <> 0 Then
    objNetwork.RemoveNetworkDrive "F:", True, True
    objNetwork.MapNetworkDrive "F:", "\\crwin.crnet.org\DFS\BUS\DEPT\FM1\MARKETING\MARKETING"
  End If
End If


If IsMember(objUser, "FS-SCIENTIFIC-FUNDING-COMMITTEE-BUDGETS") Then
  On Error Resume Next
  objNetwork.MapNetworkDrive "M:", "\\crwin.crnet.org\dfs\bus\Data\CR-UK\RS\SCIENTIFIC\SCIENTIFIC\FUNDING COMMITTEE BUDGETS"
If Err.Number <> 0 Then
    objNetwork.RemoveNetworkDrive "M:", True, True
    objNetwork.MapNetworkDrive "M:", "\\crwin.crnet.org\dfs\bus\Data\CR-UK\RS\SCIENTIFIC\SCIENTIFIC\FUNDING COMMITTEE BUDGETS"
  End If
End If

If IsMember(objUser, "FS-LEGACIES") Then
  On Error Resume Next
  objNetwork.MapNetworkDrive "F:", "\\crwin.crnet.org\DFS\BUS\DEPT\FM\LEGACIES\LEGACIES"
If Err.Number <> 0 Then
    objNetwork.RemoveNetworkDrive "F:", True, True
    objNetwork.MapNetworkDrive "F:", "\\crwin.crnet.org\DFS\BUS\DEPT\FM\LEGACIES\LEGACIES"
  End If
End If



If IsMember(objUser, "FS-BUSINESS-ANALYSIS") Then
  On Error Resume Next
  objNetwork.MapNetworkDrive "F:", "\\crwin.crnet.org\DFS\BUS\DEPT\FM\BUSINESS\BUSINESS ANALYSIS"
If Err.Number <> 0 Then
    objNetwork.RemoveNetworkDrive "F:", True, True
    objNetwork.MapNetworkDrive "F:", "\\crwin.crnet.org\DFS\BUS\DEPT\FM\BUSINESS\BUSINESS ANALYSIS"
  End If
End If



If IsMember(objUser, "FS-EBUSINESS") Then
  On Error Resume Next
  objNetwork.MapNetworkDrive "F:", "\\crwin.crnet.org\DFS\BUS\DEPT\FM\BUSINESS\EBUSINESS"
If Err.Number <> 0 Then
    objNetwork.RemoveNetworkDrive "F:", True, True
    objNetwork.MapNetworkDrive "F:", "\\crwin.crnet.org\DFS\BUS\DEPT\FM\BUSINESS\EBUSINESS"
  End If
End If

If IsMember(objUser, "FM - E-Business") Then
  On Error Resume Next
  objNetwork.MapNetworkDrive "F:", "\\crwin.crnet.org\DFS\BUS\DEPT\FM\BUSINESS\EBUSINESS"
If Err.Number <> 0 Then
    objNetwork.RemoveNetworkDrive "F:", True, True
    objNetwork.MapNetworkDrive "F:", "\\crwin.crnet.org\DFS\BUS\DEPT\FM\BUSINESS\EBUSINESS"
  End If
End If

If IsMember(objUser, "FS-APP-CLSERVER-CT") Then
  On Error Resume Next
  objNetwork.MapNetworkDrive "Q:", "\\crwin.crnet.org\dfs\bus\CLSERVER"
If Err.Number <> 0 Then
    objNetwork.RemoveNetworkDrive "Q:", True, True
    objNetwork.MapNetworkDrive "Q:", "\\crwin.crnet.org\dfs\bus\CLSERVER"
  End If
End If

If IsMember(objUser, "FS-RETAIL-SECURITY") Then
  On Error Resume Next
  objNetwork.MapNetworkDrive "G:", "\\crwin.crnet.org\DFS\BUS\DEPT\FM\RETAIL\GROUPS"
If Err.Number <> 0 Then
    objNetwork.RemoveNetworkDrive "G:", True, True
    objNetwork.MapNetworkDrive "G:", "\\crwin.crnet.org\DFS\BUS\DEPT\FM\RETAIL\GROUPS"
  End If
End If

If IsMember(objUser, "FS-RETAIL-HORSHAM") Then
  On Error Resume Next
  objNetwork.MapNetworkDrive "G:", "\\crwin.crnet.org\DFS\BUS\DEPT\FM\RETAIL\GROUPS"
If Err.Number <> 0 Then
    objNetwork.RemoveNetworkDrive "G:", True, True
    objNetwork.MapNetworkDrive "G:", "\\crwin.crnet.org\DFS\BUS\DEPT\FM\RETAIL\GROUPS"
  End If
End If

'If IsMember(objUser, "FS-RETAIL-CENTRAL-OPERATIONS") Then
'  On Error Resume Next
'  objNetwork.MapNetworkDrive "G:", "\\crwin.crnet.org\DFS\BUS\DEPT\FM\RETAIL\GROUPS\RETAIL HORSHAM\CENTRAL OPERATIONS"
'If Err.Number <> 0 Then
'    objNetwork.RemoveNetworkDrive "G:", True, True
'    objNetwork.MapNetworkDrive "G:", "\\crwin.crnet.org\DFS\BUS\DEPT\FM\RETAIL\GROUPS\RETAIL HORSHAM\CENTRAL OPERATIONS"
'  End If
'End If


If IsMember(objUser, "FS-RETAIL") Then
  On Error Resume Next
  objNetwork.MapNetworkDrive "F:", "\\crwin.crnet.org\DFS\BUS\DEPT\FM\RETAIL\RETAIL"
If Err.Number <> 0 Then
    objNetwork.RemoveNetworkDrive "F:", True, True
    objNetwork.MapNetworkDrive "F:", "\\crwin.crnet.org\DFS\BUS\DEPT\FM\RETAIL\RETAIL"
  End If
End If

If IsMember(objUser, "FS-CMG") Then
  On Error Resume Next
  objNetwork.MapNetworkDrive "F:", "\\crwin.crnet.org\DFS\BUS\DEPT\FM\CMG\CMG"
If Err.Number <> 0 Then
    objNetwork.RemoveNetworkDrive "F:", True, True
    objNetwork.MapNetworkDrive "F:", "\\crwin.crnet.org\DFS\BUS\DEPT\FM\CMG\CMG"
  End If
End If

If IsMember(objUser, "FS-CMG-CORPORATE") Then
  On Error Resume Next
  objNetwork.MapNetworkDrive "G:", "\\crwin.crnet.org\DFS\BUS\DEPT\FM\CMG\GROUPS"
If Err.Number <> 0 Then
    objNetwork.RemoveNetworkDrive "G:", True, True
    objNetwork.MapNetworkDrive "G:", "\\crwin.crnet.org\DFS\BUS\DEPT\FM\CMG\GROUPS"
  End If
End If

If IsMember(objUser, "FS-CMG-PROJECT-FUNDRAISING") Then
  On Error Resume Next
  objNetwork.MapNetworkDrive "G:", "\\crwin.crnet.org\DFS\BUS\DEPT\FM\CMG\GROUPS"
If Err.Number <> 0 Then
    objNetwork.RemoveNetworkDrive "G:", True, True
    objNetwork.MapNetworkDrive "G:", "\\crwin.crnet.org\DFS\BUS\DEPT\FM\CMG\GROUPS"
  End If
End If

If IsMember(objUser, "FS-PDV") Then
  On Error Resume Next
  objNetwork.MapNetworkDrive "F:", "\\crwin.crnet.org\DFS\BUS\DEPT\FM\PDV"
If Err.Number <> 0 Then
    objNetwork.RemoveNetworkDrive "F:", True, True
    objNetwork.MapNetworkDrive "F:", "\\crwin.crnet.org\DFS\BUS\DEPT\FM\PDV"
  End If
End If

If IsMember(objUser, "FS-CRM") Then
  On Error Resume Next
  objNetwork.MapNetworkDrive "K:", "\\CRWIN.CRNET.ORG\DFS\BUS\DEPT\LSF\CRM"
If Err.Number <> 0 Then
    objNetwork.RemoveNetworkDrive "K:", True, True
    objNetwork.MapNetworkDrive "K:", "\\CRWIN.CRNET.ORG\DFS\BUS\DEPT\LSF\CRM"
  End If
End If


If IsMember(objUser, "FS-NED-SUPPORT-SYSTEMS") Then
  On Error Resume Next
  objNetwork.MapNetworkDrive "G:", "\\crwin.crnet.org\DFS\BUS\DEPT\FM\NED\GROUPS"
If Err.Number <> 0 Then
    objNetwork.RemoveNetworkDrive "G:", True, True
    objNetwork.MapNetworkDrive "G:", "\\crwin.crnet.org\DFS\BUS\DEPT\FM\NED\GROUPS"
  End If
End If


If IsMember(objUser, "FS-NED-SENIOR-MANAGEMENT") Then
  On Error Resume Next
  objNetwork.MapNetworkDrive "G:", "\\crwin.crnet.org\DFS\BUS\DEPT\FM\NED\GROUPS"
If Err.Number <> 0 Then
    objNetwork.RemoveNetworkDrive "G:", True, True
    objNetwork.MapNetworkDrive "G:", "\\crwin.crnet.org\DFS\BUS\DEPT\FM\NED\GROUPS"
  End If
End If


If IsMember(objUser, "FS-NED-SPECIAL-EVENTS") Then
  On Error Resume Next
  objNetwork.MapNetworkDrive "G:", "\\crwin.crnet.org\DFS\BUS\DEPT\FM\NED\GROUPS"
If Err.Number <> 0 Then
    objNetwork.RemoveNetworkDrive "G:", True, True
    objNetwork.MapNetworkDrive "G:", "\\crwin.crnet.org\DFS\BUS\DEPT\FM\NED\GROUPS"
  End If
End If


If IsMember(objUser, "FS-NED-RUNNING-TREKING-CYCLING") Then
  On Error Resume Next
  objNetwork.MapNetworkDrive "G:", "\\crwin.crnet.org\DFS\BUS\DEPT\FM\NED\GROUPS"
If Err.Number <> 0 Then
    objNetwork.RemoveNetworkDrive "G:", True, True
    objNetwork.MapNetworkDrive "G:", "\\crwin.crnet.org\DFS\BUS\DEPT\FM\NED\GROUPS"
  End If
End If


If IsMember(objUser, "FS-NED") Then
  On Error Resume Next
  objNetwork.MapNetworkDrive "F:", "\\crwin.crnet.org\DFS\BUS\DEPT\FM\NED\NED"
If Err.Number <> 0 Then
    objNetwork.RemoveNetworkDrive "F:", True, True
    objNetwork.MapNetworkDrive "F:", "\\crwin.crnet.org\DFS\BUS\DEPT\FM\NED\NED"
  End If
End If


If IsMember(objUser, "Role - CR - Procurement") Then
  On Error Resume Next
  objNetwork.MapNetworkDrive "F:", "\\crwin.crnet.org\dfs\bus\Data\CR-UK\FI\Finance\finance"
If Err.Number <> 0 Then
    objNetwork.RemoveNetworkDrive "F:", True, True
    objNetwork.MapNetworkDrive "F:", "\\crwin.crnet.org\dfs\bus\Data\CR-UK\FI\Finance\finance"
  End If
End If


If IsMember(objUser, "Role - CR - Procurement") Then
  On Error Resume Next
  objNetwork.MapNetworkDrive "G:", "\\crwin.crnet.org\dfs\bus\Data\CR-UK\FI\Finance\Groups"
If Err.Number <> 0 Then
    objNetwork.RemoveNetworkDrive "G:", True, True
    objNetwork.MapNetworkDrive "G:", "\\crwin.crnet.org\dfs\bus\Data\CR-UK\FI\Finance\Groups"
  End If
End If


If IsMember(objUser, "FS-STORES") Then
  On Error Resume Next
  objNetwork.MapNetworkDrive "F:", "\\crwin.crnet.org\dfs\bus\Data\CR-UK\RS\STORES\STORES"
If Err.Number <> 0 Then
    objNetwork.RemoveNetworkDrive "F:", True, True
    objNetwork.MapNetworkDrive "F:", "\\crwin.crnet.org\dfs\bus\Data\CR-UK\RS\STORES\STORES"
  End If
End If

If IsMember(objUser, "FS-HEALTH-&-SAFETY") Then
  On Error Resume Next
  objNetwork.MapNetworkDrive "F:", "\\crwin.crnet.org\dfs\bus\Data\CR-UK\RS\H&S\H&S"
If Err.Number <> 0 Then
    objNetwork.RemoveNetworkDrive "F:", True, True
    objNetwork.MapNetworkDrive "F:", "\\crwin.crnet.org\dfs\bus\Data\CR-UK\RS\H&S\H&S"
  End If
End If

' Map a network drive letter to the UNC path if the user is a member of the group specified in IsMember(objUser, "AD GROUP NAME") 
If IsMember(objUser, "FS-PRS-PROPERTY-SERVICES") Then
  On Error Resume Next
  objNetwork.MapNetworkDrive "G:", "\\CRWIN.CRNET.ORG\DFS\BUS\DEPT\PRS"
  If Err.Number <> 0 Then
    objNetwork.RemoveNetworkDrive "G:", True, True
    objNetwork.MapNetworkDrive "G:", "\\CRWIN.CRNET.ORG\DFS\BUS\DEPT\PRS"
  End If
End If

If IsMember(objUser, "FS-COMMUNICATIONS") Then
  On Error Resume Next
  objNetwork.MapNetworkDrive "F:", "\\crwin.crnet.org\dfs\bus\Data\CR-UK\PC\COMMUNICATIONS\COMMUNICATIONS"
If Err.Number <> 0 Then
    objNetwork.RemoveNetworkDrive "F:", True, True
    objNetwork.MapNetworkDrive "F:", "\\crwin.crnet.org\dfs\bus\Data\CR-UK\PC\COMMUNICATIONS\COMMUNICATIONS"
  End If
End If

If IsMember(objUser, "FS-COMMUNICATIONS-CANCER-INFORMATION") Then
  On Error Resume Next
  objNetwork.MapNetworkDrive "G:", "\\crwin.crnet.org\dfs\bus\Data\CR-UK\PC\COMMUNICATIONS\GROUPS"
If Err.Number <> 0 Then
    objNetwork.RemoveNetworkDrive "G:", True, True
    objNetwork.MapNetworkDrive "G:", "\\crwin.crnet.org\dfs\bus\Data\CR-UK\PC\COMMUNICATIONS\GROUPS"
  End If
End If

If IsMember(objUser, "FS-COMMUNICATIONS-INTERNAL-&-EXTERNAL-AFFAIRS") Then
  On Error Resume Next
  objNetwork.MapNetworkDrive "G:", "\\crwin.crnet.org\dfs\bus\Data\CR-UK\PC\COMMUNICATIONS\GROUPS"
If Err.Number <> 0 Then
    objNetwork.RemoveNetworkDrive "G:", True, True
    objNetwork.MapNetworkDrive "G:", "\\crwin.crnet.org\dfs\bus\Data\CR-UK\PC\COMMUNICATIONS\GROUPS"
  End If
End If

If IsMember(objUser, "FS-COMMUNICATIONS-MEDIA") Then
  On Error Resume Next
  objNetwork.MapNetworkDrive "G:", "\\crwin.crnet.org\dfs\bus\Data\CR-UK\PC\COMMUNICATIONS\GROUPS"
If Err.Number <> 0 Then
    objNetwork.RemoveNetworkDrive "G:", True, True
    objNetwork.MapNetworkDrive "G:", "\\crwin.crnet.org\dfs\bus\Data\CR-UK\PC\COMMUNICATIONS\GROUPS"
  End If
End If

If IsMember(objUser, "FS-COMMUNICATIONS-READ-ONLY-MEDIA") Then
  On Error Resume Next
  objNetwork.MapNetworkDrive "G:", "\\crwin.crnet.org\dfs\bus\Data\CR-UK\PC\COMMUNICATIONS\GROUPS"
If Err.Number <> 0 Then
    objNetwork.RemoveNetworkDrive "G:", True, True
    objNetwork.MapNetworkDrive "G:", "\\crwin.crnet.org\dfs\bus\Data\CR-UK\PC\COMMUNICATIONS\GROUPS"
  End If
End If

If IsMember(objUser, "FS-FACS-LAB") Then
  On Error Resume Next
  objNetwork.MapNetworkDrive "F:", "\\crwin.crnet.org\dfs\bus\Data\CR-UK\RS\SCIENTIFIC\GROUPS"
If Err.Number <> 0 Then
    objNetwork.RemoveNetworkDrive "F:", True, True
    objNetwork.MapNetworkDrive "F:", "\\crwin.crnet.org\dfs\bus\Data\CR-UK\RS\SCIENTIFIC\GROUPS"
  End If
End If

If IsMember(objUser, "FS-SCIENTIFIC-BEHAVIOURAL") Then
  On Error Resume Next
  objNetwork.MapNetworkDrive "G:", "\\crwin.crnet.org\dfs\bus\Data\CR-UK\RS\SCIENTIFIC\GROUPS"
If Err.Number <> 0 Then
    objNetwork.RemoveNetworkDrive "G:", True, True
    objNetwork.MapNetworkDrive "G:", "\\crwin.crnet.org\dfs\bus\Data\CR-UK\RS\SCIENTIFIC\GROUPS"
  End If
End If

' Map a network drive letter to the UNC path if the user is a member of the group specified in IsMember(objUser, "AD GROUP NAME") 
If IsMember(objUser, "FS-ARCHIVED-SCIENTIFIC-DATABASES") Then
  On Error Resume Next
  objNetwork.MapNetworkDrive "G:", "\\crwin.crnet.org\dfs\bus\Data\CR-UK\RS\SCIENTIFIC\GROUPS"
If Err.Number <> 0 Then
    objNetwork.RemoveNetworkDrive "G:", True, True
    objNetwork.MapNetworkDrive "G:", "\\crwin.crnet.org\dfs\bus\Data\CR-UK\RS\SCIENTIFIC\GROUPS"
  End If
End If

' Map a network drive letter to the UNC path if the user is a member of the group specified in IsMember(objUser, "AD GROUP NAME") 
If IsMember(objUser, "FS-DDO-SCIENTIFIC") Then
  On Error Resume Next
  objNetwork.MapNetworkDrive "I:", "\\crwin.crnet.org\dfs\bus\Data\CR-UK\RS\SCIENTIFIC\SCIENTIFIC"
If Err.Number <> 0 Then
    objNetwork.RemoveNetworkDrive "I:", True, True
    objNetwork.MapNetworkDrive "I:", "\\crwin.crnet.org\dfs\bus\Data\CR-UK\RS\SCIENTIFIC\SCIENTIFIC"
  End If
End If

If IsMember(objUser, "FS-BJC") Then
  On Error Resume Next
  objNetwork.MapNetworkDrive "I:", "\\crwin.crnet.org\dfs\bus\Data\CR-UK\RS\BJC"
If Err.Number <> 0 Then
    objNetwork.RemoveNetworkDrive "I:", True, True
    objNetwork.MapNetworkDrive "I:", "\\crwin.crnet.org\dfs\bus\Data\CR-UK\RS\BJC"
  End If
End If

' Map a network drive letter to the UNC path if the user is a member of the group specified in IsMember(objUser, "AD GROUP NAME") 
If IsMember(objUser, "FS-SCIENTIFIC") Then
  On Error Resume Next
  objNetwork.MapNetworkDrive "F:", "\\crwin.crnet.org\dfs\bus\Data\CR-UK\RS\SCIENTIFIC\SCIENTIFIC"
If Err.Number <> 0 Then
    objNetwork.RemoveNetworkDrive "F:", True, True
    objNetwork.MapNetworkDrive "F:", "\\crwin.crnet.org\dfs\bus\Data\CR-UK\RS\SCIENTIFIC\SCIENTIFIC"
  End If
End If


' Map a network drive letter to the UNC path if the user is a member of the group specified in IsMember(objUser, "AD GROUP NAME") 
If IsMember(objUser, "FS-DDO") Then
  On Error Resume Next
  objNetwork.MapNetworkDrive "F:", "\\crwin.crnet.org\dfs\bus\dept\ddo\DDO\DDO"
If Err.Number <> 0 Then
    objNetwork.RemoveNetworkDrive "F:", True, True
    objNetwork.MapNetworkDrive "F:", "\\crwin.crnet.org\dfs\bus\dept\ddo\DDO\DDO"
  End If
End If


' Map a network drive letter to the UNC path if the user is a member of the group specified in IsMember(objUser, "AD GROUP NAME") 
If IsMember(objUser, "FS-DDO-NEW") Then
  On Error Resume Next
  objNetwork.MapNetworkDrive "J:", "\\INDRA\RS\DDO_NEW\DDO"
If Err.Number <> 0 Then
    objNetwork.RemoveNetworkDrive "J:", True, True
    objNetwork.MapNetworkDrive "J:", "\\INDRA\RS\DDO_NEW\DDO"
  End If
End If


' Map a network drive letter to the UNC path if the user is a member of the group specified in IsMember(objUser, "AD GROUP NAME") 
If IsMember(objUser, "FS-PENSIONS") Then
  On Error Resume Next
  objNetwork.MapNetworkDrive "F:", "\\crwin.crnet.org\dfs\bus\Data\CR-UK\OD\PENSIONS\PENSIONS"
  If Err.Number <> 0 Then
    objNetwork.RemoveNetworkDrive "F:", True, True
    objNetwork.MapNetworkDrive "F:", "\\crwin.crnet.org\dfs\bus\Data\CR-UK\OD\PENSIONS\PENSIONS"
  End If
End If



' Map a network drive letter to the UNC path if the user is a member of the group specified in IsMember(objUser, "AD GROUP NAME") 
If IsMember(objUser, "FS-FINANCE-BANK-RECONCILIATION") Then
  On Error Resume Next
  objNetwork.MapNetworkDrive "G:", "\\crwin.crnet.org\dfs\bus\Data\CR-UK\FI\FINANCE\GROUPS"
  If Err.Number <> 0 Then
    objNetwork.RemoveNetworkDrive "G:", True, True
    objNetwork.MapNetworkDrive "G:", "\\crwin.crnet.org\dfs\bus\Data\CR-UK\FI\FINANCE\GROUPS"
  End If
End If

' Map a network drive letter to the UNC path if the user is a member of the group specified in IsMember(objUser, "AD GROUP NAME") 
If IsMember(objUser, "FS-FINANCE-DONATION-PROCESSING") Then
  On Error Resume Next
  objNetwork.MapNetworkDrive "G:", "\\crwin.crnet.org\dfs\bus\Data\CR-UK\FI\FINANCE\GROUPS"
  If Err.Number <> 0 Then
    objNetwork.RemoveNetworkDrive "G:", True, True
    objNetwork.MapNetworkDrive "G:", "\\crwin.crnet.org\dfs\bus\Data\CR-UK\FI\FINANCE\GROUPS"
  End If
End If

' Map a network drive letter to the UNC path if the user is a member of the group specified in IsMember(objUser, "AD GROUP NAME") 
If IsMember(objUser, "FS-FINANCE-FINANCE-DIRECTORATE") Then
  On Error Resume Next
  objNetwork.MapNetworkDrive "G:", "\\crwin.crnet.org\dfs\bus\Data\CR-UK\FI\FINANCE\GROUPS"
  If Err.Number <> 0 Then
    objNetwork.RemoveNetworkDrive "G:", True, True
    objNetwork.MapNetworkDrive "G:", "\\crwin.crnet.org\dfs\bus\Data\CR-UK\FI\FINANCE\GROUPS"
  End If
End If

' Map a network drive letter to the UNC path if the user is a member of the group specified in IsMember(objUser, "AD GROUP NAME") 
If IsMember(objUser, "FS-FINANCE-EXPENDITURE-PROCESSING") Then
  On Error Resume Next
  objNetwork.MapNetworkDrive "G:", "\\crwin.crnet.org\dfs\bus\Data\CR-UK\FI\FINANCE\GROUPS"
  If Err.Number <> 0 Then
    objNetwork.RemoveNetworkDrive "G:", True, True
    objNetwork.MapNetworkDrive "G:", "\\crwin.crnet.org\dfs\bus\Data\CR-UK\FI\FINANCE\GROUPS"
  End If
End If

' Map a network drive letter to the UNC path if the user is a member of the group specified in IsMember(objUser, "AD GROUP NAME") 
If IsMember(objUser, "FS-FINANCE-FINANCIAL-REPORTING") Then
  On Error Resume Next
  objNetwork.MapNetworkDrive "G:", "\\crwin.crnet.org\dfs\bus\Data\CR-UK\FI\FINANCE\GROUPS"
  If Err.Number <> 0 Then
    objNetwork.RemoveNetworkDrive "G:", True, True
    objNetwork.MapNetworkDrive "G:", "\\crwin.crnet.org\dfs\bus\Data\CR-UK\FI\FINANCE\GROUPS"
  End If
End If

' Map a network drive letter to the UNC path if the user is a member of the group specified in IsMember(objUser, "AD GROUP NAME") 
If IsMember(objUser, "FS-FINANCE-MANAGERS") Then
  On Error Resume Next
  objNetwork.MapNetworkDrive "G:", "\\crwin.crnet.org\dfs\bus\Data\CR-UK\FI\FINANCE\GROUPS"
  If Err.Number <> 0 Then
    objNetwork.RemoveNetworkDrive "G:", True, True
    objNetwork.MapNetworkDrive "G:", "\\crwin.crnet.org\dfs\bus\Data\CR-UK\FI\FINANCE\GROUPS"
  End If
End If

' Map a network drive letter to the UNC path if the user is a member of the group specified in IsMember(objUser, "AD GROUP NAME") 
If IsMember(objUser, "FS-FINANCE-MANAGEMENT-REPORTING") Then
  On Error Resume Next
  objNetwork.MapNetworkDrive "G:", "\\crwin.crnet.org\dfs\bus\Data\CR-UK\FI\FINANCE\GROUPS"
  If Err.Number <> 0 Then
    objNetwork.RemoveNetworkDrive "G:", True, True
    objNetwork.MapNetworkDrive "G:", "\\crwin.crnet.org\dfs\bus\Data\CR-UK\FI\FINANCE\GROUPS"
  End If
End If

' Map a network drive letter to the UNC path if the user is a member of the group specified in IsMember(objUser, "AD GROUP NAME") 
If IsMember(objUser, "FS-FINANCE-PROJECT-DEVELOPMENT") Then
  On Error Resume Next
  objNetwork.MapNetworkDrive "G:", "\\crwin.crnet.org\dfs\bus\Data\CR-UK\FI\FINANCE\GROUPS"
  If Err.Number <> 0 Then
    objNetwork.RemoveNetworkDrive "G:", True, True
    objNetwork.MapNetworkDrive "G:", "\\crwin.crnet.org\dfs\bus\Data\CR-UK\FI\FINANCE\GROUPS"
  End If
End If

' Map a network drive letter to the UNC path if the user is a member of the group specified in IsMember(objUser, "AD GROUP NAME") 
If IsMember(objUser, "FS-FINANCE") Then
  On Error Resume Next
 objNetwork.MapNetworkDrive "F:", "\\crwin.crnet.org\dfs\bus\Data\CR-UK\FI\FINANCE\FINANCE"
  If Err.Number <> 0 Then
    objNetwork.RemoveNetworkDrive "F:", True, True
    objNetwork.MapNetworkDrive "F:", "\\crwin.crnet.org\dfs\bus\Data\CR-UK\FI\FINANCE\FINANCE"
  End If
End If

' Map a network drive letter to the UNC path if the user is a member of the group specified in IsMember(objUser, "AD GROUP NAME") 
If IsMember(objUser, "FS-FINANCE-FBA-SBA") Then
  On Error Resume Next
 objNetwork.MapNetworkDrive "I:", "\\crwin.crnet.org\dfs\bus\Data\CR-UK\FI\FINANCE\FINANCE"
  If Err.Number <> 0 Then
    objNetwork.RemoveNetworkDrive "I:", True, True
    objNetwork.MapNetworkDrive "I:", "\\crwin.crnet.org\dfs\bus\Data\CR-UK\FI\FINANCE\FINANCE"
  End If
End If

' Map a network drive letter to the UNC path if the user is a member of the group specified in IsMember(objUser, "AD GROUP NAME") 
If IsMember(objUser, "FS-IS-ALLIT") Then
  On Error Resume Next
 objNetwork.MapNetworkDrive "F:", "\\CRWIN.CRNET.ORG\DFS\BUS\DEPT\ISD\ALLIT"
  If Err.Number <> 0 Then
    objNetwork.RemoveNetworkDrive "F:", True, True
    objNetwork.MapNetworkDrive "F:", "\\CRWIN.CRNET.ORG\DFS\BUS\DEPT\ISD\ALLIT"
  End If
End If

' Map a network drive letter to the UNC path if the user is a member of the group specified in IsMember(objUser, "AD GROUP NAME") 
If IsMember(objUser, "FS-IS-TRAINING") Then
  On Error Resume Next
  objNetwork.MapNetworkDrive "G:", "\\CRWIN.CRNET.ORG\DFS\BUS\DEPT\ISD\GROUPS"
  If Err.Number <> 0 Then
    objNetwork.RemoveNetworkDrive "G:", True, True
    objNetwork.MapNetworkDrive "G:", "\\CRWIN.CRNET.ORG\DFS\BUS\DEPT\ISD\GROUPS"
  End If
End If


' Map a network drive letter to the UNC path if the user is a member of the group specified in IsMember(objUser, "AD GROUP NAME") 
If IsMember(objUser, "FS-IS-STUDENT-TRAINING") Then
  On Error Resume Next
  objNetwork.MapNetworkDrive "F:", "\\CRWIN.CRNET.ORG\DFS\BUS\DEPT\ISD\GROUPS\TRAINING\STUDENT-TRAINING"
  If Err.Number <> 0 Then
    objNetwork.RemoveNetworkDrive "F:", True, True
    objNetwork.MapNetworkDrive "F:", "\\CRWIN.CRNET.ORG\DFS\BUS\DEPT\ISD\GROUPS\TRAINING\STUDENT-TRAINING"
  End If
End If

' Map a network drive letter to the UNC path if the user is a member of the group specified in IsMember(objUser, "AD GROUP NAME") 
If IsMember(objUser, "FS-CUSTOMER-AND-DESKTOP-SERVICES") Then
  On Error Resume Next
  objNetwork.MapNetworkDrive "G:", "\\CRWIN.CRNET.ORG\DFS\BUS\DEPT\ISD\GROUPS"
  If Err.Number <> 0 Then
    objNetwork.RemoveNetworkDrive "G:", True, True
    objNetwork.MapNetworkDrive "G:", "\\CRWIN.CRNET.ORG\DFS\BUS\DEPT\ISD\GROUPS"
  End If
End If


' Map a network drive letter to the UNC path if the user is a member of the group specified in IsMember(objUser, "AD GROUP NAME") 
If IsMember(objUser, "FS-IS-USER-AND-SERVICES-SUPPORT") Then
  On Error Resume Next
  objNetwork.MapNetworkDrive "G:", "\\CRWIN.CRNET.ORG\DFS\BUS\DEPT\ISD\GROUPS"
  If Err.Number <> 0 Then
    objNetwork.RemoveNetworkDrive "G:", True, True
    objNetwork.MapNetworkDrive "G:", "\\CRWIN.CRNET.ORG\DFS\BUS\DEPT\ISD\GROUPS"
  End If
End If

' Map a network drive letter to the UNC path if the user is a member of the group specified in IsMember(objUser, "AD GROUP NAME") 
If IsMember(objUser, "FS-DEVELOPMENT") Then
  On Error Resume Next
  objNetwork.MapNetworkDrive "G:", "\\CRWIN.CRNET.ORG\DFS\BUS\DEPT\ISD\GROUPS"
  If Err.Number <> 0 Then
    objNetwork.RemoveNetworkDrive "G:", True, True
    objNetwork.MapNetworkDrive "G:", "\\CRWIN.CRNET.ORG\DFS\BUS\DEPT\ISD\GROUPS"
  End If
End If

' Map a network drive letter to the UNC path if the user is a member of the group specified in IsMember(objUser, "AD GROUP NAME") 
If IsMember(objUser, "FS-INFRASTRUCTURE") Then
  On Error Resume Next
  objNetwork.MapNetworkDrive "G:", "\\CRWIN.CRNET.ORG\DFS\BUS\DEPT\ISD\GROUPS"
  If Err.Number <> 0 Then
    objNetwork.RemoveNetworkDrive "G:", True, True
    objNetwork.MapNetworkDrive "G:", "\\CRWIN.CRNET.ORG\DFS\BUS\DEPT\ISD\GROUPS"
  End If
End If

' Map a network drive letter to the UNC path if the user is a member of the group specified in IsMember(objUser, "AD GROUP NAME") 
If IsMember(objUser, "FS-IS-SHARED-SERVICES") Then
  On Error Resume Next
  objNetwork.MapNetworkDrive "G:", "\\CRWIN.CRNET.ORG\DFS\BUS\DEPT\ISD\GROUPS\SHARED SERVICES"
  If Err.Number <> 0 Then
    objNetwork.RemoveNetworkDrive "G:", True, True
    objNetwork.MapNetworkDrive "G:", "\\CRWIN.CRNET.ORG\DFS\BUS\DEPT\ISD\GROUPS\SHARED SERVICES"
  End If
End If

' Map a network drive letter to the UNC path if the user is a member of the group specified in IsMember(objUser, "AD GROUP NAME") 
If IsMember(objUser, "FS-IS-SOFTWARE") Then
  On Error Resume Next
  objNetwork.MapNetworkDrive "S:", "\\CRWIN.CRNET.ORG\DFS\BUS\INSTALL\SOFTWARE"
  If Err.Number <> 0 Then
    objNetwork.RemoveNetworkDrive "S:", True, True
    objNetwork.MapNetworkDrive "S:", "\\CRWIN.CRNET.ORG\DFS\BUS\INSTALL\SOFTWARE"
  End If
End If

' Map a network drive letter to the UNC path if the user is a member of the group specified in IsMember(objUser, "AD GROUP NAME") 
If IsMember(objUser, "FS-HR-DIRECTORATE") Then
  On Error Resume Next
  objNetwork.MapNetworkDrive "G:", "\\crwin.crnet.org\dfs\bus\Data\CR-UK\OD\PERSONNEL\GROUPS"
  If Err.Number <> 0 Then
    objNetwork.RemoveNetworkDrive "G:", True, True
    objNetwork.MapNetworkDrive "G:", "\\crwin.crnet.org\dfs\bus\Data\CR-UK\OD\PERSONNEL\GROUPS"
  End If
End If

' Map a network drive letter to the UNC path if the user is a member of the group specified in IsMember(objUser, "AD GROUP NAME") 
If IsMember(objUser, "FS-PERSONNEL") Then
  On Error Resume Next
  objNetwork.MapNetworkDrive "F:", "\\crwin.crnet.org\dfs\bus\Data\CR-UK\OD\PERSONNEL\PERSONNEL"
  If Err.Number <> 0 Then
    objNetwork.RemoveNetworkDrive "F:", True, True
    objNetwork.MapNetworkDrive "F:", "\\crwin.crnet.org\dfs\bus\Data\CR-UK\OD\PERSONNEL\PERSONNEL"
  End If
End If

' Map a network drive letter to the UNC path if the user is a member of the group specified in IsMember(objUser, "AD GROUP NAME") 
If IsMember(objUser, "FS-PERSONNEL-TRAINING") Then
  On Error Resume Next
  objNetwork.MapNetworkDrive "G:", "\\crwin.crnet.org\dfs\bus\Data\CR-UK\OD\PERSONNEL\GROUPS"
  If Err.Number <> 0 Then
    objNetwork.RemoveNetworkDrive "G:", True, True
    objNetwork.MapNetworkDrive "G:", "\\crwin.crnet.org\dfs\bus\Data\CR-UK\OD\PERSONNEL\GROUPS"
  End If
End If

' Map a network drive letter to the UNC path if the user is a member of the group specified in IsMember(objUser, "AD GROUP NAME") 
If IsMember(objUser, "FS-REWARD") Then
  On Error Resume Next
  objNetwork.MapNetworkDrive "G:", "\\crwin.crnet.org\dfs\bus\Data\CR-UK\OD\PERSONNEL\GROUPS"
  If Err.Number <> 0 Then
    objNetwork.RemoveNetworkDrive "G:", True, True
    objNetwork.MapNetworkDrive "G:", "\\crwin.crnet.org\dfs\bus\Data\CR-UK\OD\PERSONNEL\GROUPS"
  End If
End If

' Map a network drive letter to the UNC path if the user is a member of the group specified in IsMember(objUser, "AD GROUP NAME") 
If IsMember(objUser, "FS-RECRUITMENT") Then
  On Error Resume Next
  objNetwork.MapNetworkDrive "G:", "\\crwin.crnet.org\dfs\bus\Data\CR-UK\OD\PERSONNEL\GROUPS"
  If Err.Number <> 0 Then
    objNetwork.RemoveNetworkDrive "G:", True, True
    objNetwork.MapNetworkDrive "G:", "\\crwin.crnet.org\dfs\bus\Data\CR-UK\OD\PERSONNEL\GROUPS"
  End If
End If

' Map a network drive letter to the UNC path if the user is a member of the group specified in IsMember(objUser, "AD GROUP NAME") 
If IsMember(objUser, "FS-EMPLOYEE-RELATIONS") Then
  On Error Resume Next
  objNetwork.MapNetworkDrive "G:", "\\crwin.crnet.org\dfs\bus\Data\CR-UK\OD\PERSONNEL\GROUPS"
  If Err.Number <> 0 Then
    objNetwork.RemoveNetworkDrive "G:", True, True
    objNetwork.MapNetworkDrive "G:", "\\crwin.crnet.org\dfs\bus\Data\CR-UK\OD\PERSONNEL\GROUPS"
  End If
End If

' Map a network drive letter to the UNC path if the user is a member of the group specified in IsMember(objUser, "AD GROUP NAME") 
If IsMember(objUser, "FS-OHD") Then
  On Error Resume Next
  objNetwork.MapNetworkDrive "F:", "\\crwin.crnet.org\dfs\bus\Data\CR-UK\OD\OHD"
If Err.Number <> 0 Then
    objNetwork.RemoveNetworkDrive "F:", True, True
    objNetwork.MapNetworkDrive "F:", "\\crwin.crnet.org\dfs\bus\Data\CR-UK\OD\OHD"
  End If
End If

' Map a network drive letter to the UNC path if the user is a member of the group specified in IsMember(objUser, "AD GROUP NAME") 
If IsMember(objUser, "FS-PAYROLL") Then
  On Error Resume Next
  objNetwork.MapNetworkDrive "F:", "\\crwin.crnet.org\dfs\bus\Data\CR-UK\OD\PAYROLL"
If Err.Number <> 0 Then
    objNetwork.RemoveNetworkDrive "F:", True, True
    objNetwork.MapNetworkDrive "F:", "\\crwin.crnet.org\dfs\bus\Data\CR-UK\OD\PAYROLL"
  End If
End If

' Map a network drive letter to the UNC path if the user is a member of the group specified in IsMember(objUser, "AD GROUP NAME") 
If IsMember(objUser, "ncri-sec-csg") Then
  On Error Resume Next
  objNetwork.MapNetworkDrive "K:", "\\crwin.crnet.org\dfs\bus\dept\ncri\ncri-sec-csg"
If Err.Number <> 0 Then
    objNetwork.RemoveNetworkDrive "K:", True, True
    objNetwork.MapNetworkDrive "K:", "\\crwin.crnet.org\dfs\bus\dept\ncri\ncri-sec-csg"
  End If

End If

' Map a network drive letter to the UNC path if the user is a member of the group specified in IsMember(objUser, "AD GROUP NAME") 
If IsMember(objUser, "ncri-sec-inform") Then
  On Error Resume Next
  objNetwork.MapNetworkDrive "L:", "\\crwin.crnet.org\dfs\bus\dept\ncri\ncri-sec-inform"
If Err.Number <> 0 Then
    objNetwork.RemoveNetworkDrive "L:", True, True
    objNetwork.MapNetworkDrive "L:", "\\crwin.crnet.org\dfs\bus\dept\ncri\ncri-sec-inform"
  End If
End If

If IsMember(objUser, "NCRI Informatics") Then
  On Error Resume Next
  objNetwork.MapNetworkDrive "F:", "\\crwin.crnet.org\dfs\bus\dept\ncri\informatics"
If Err.Number <> 0 Then
    objNetwork.RemoveNetworkDrive "F:", True, True
    objNetwork.MapNetworkDrive "F:", "\\crwin.crnet.org\dfs\bus\dept\ncri\informatics"
  End If
End If

If IsMember(objUser, "NCRI Admin") Then
  On Error Resume Next
  objNetwork.MapNetworkDrive "F:", "\\crwin.crnet.org\dfs\bus\dept\ncri\data"
If Err.Number <> 0 Then
    objNetwork.RemoveNetworkDrive "F:", True, True
    objNetwork.MapNetworkDrive "F:", "\\crwin.crnet.org\dfs\bus\dept\ncri\data"
  End If
End If

If IsMember(objUser, "NCRI Clinical") Then
  On Error Resume Next
  objNetwork.MapNetworkDrive "R:", "\\crwin.crnet.org\dfs\bus\dept\ncri\clinical_data"
If Err.Number <> 0 Then
    objNetwork.RemoveNetworkDrive "R:", True, True
    objNetwork.MapNetworkDrive "R:", "\\crwin.crnet.org\dfs\bus\dept\ncri\clinical_data"
  End If
End If

If IsMember(objUser, "FS-ComDev") Then
  On Error Resume Next
  objNetwork.MapNetworkDrive "F:", "\\crwin.crnet.org\dfs\bus\dept\Vol"
If Err.Number <> 0 Then
    objNetwork.RemoveNetworkDrive "F:", True, True
    objNetwork.MapNetworkDrive "F:", "\\crwin.crnet.org\dfs\bus\dept\Vol"
  End If
End If

If IsMember(objUser, "FS-CL") Then
  On Error Resume Next
  objNetwork.MapNetworkDrive "Z:", "\\crwin.crnet.org\dfs\bus\Data\CR-UK\CL"
If Err.Number <> 0 Then
    objNetwork.RemoveNetworkDrive "P:", True, True
    objNetwork.MapNetworkDrive "Z:", "\\crwin.crnet.org\dfs\bus\Data\CR-UK\CL"
  End If
End If

If IsMember(objUser, "FS-Research Engagement") Then
  On Error Resume Next
  objNetwork.MapNetworkDrive "F:", "\\crwin.crnet.org\dfs\bus\Data\CR-UK\RS\Scientific\Scientific\Sci Dept Shared Files\Centres Team\Research Engagement"
If Err.Number <> 0 Then
    objNetwork.RemoveNetworkDrive "F:", True, True
    objNetwork.MapNetworkDrive "F:", "\\crwin.crnet.org\dfs\bus\Data\CR-UK\RS\Scientific\Scientific\Sci Dept Shared Files\Centres Team\Research Engagement"
  End If
End If

If IsMember(objUser, "FS-STP") Then
  On Error Resume Next
  objNetwork.MapNetworkDrive "G:", "\\crwin.crnet.org\dfs\bus\dept\stp"
If Err.Number <> 0 Then
    objNetwork.RemoveNetworkDrive "G:", True, True
    objNetwork.MapNetworkDrive "G:", "\\crwin.crnet.org\dfs\bus\dept\stp"
  End If
End If

If IsMember(objUser, "FS-Biotherapeutics-Development-Unit") Then
  On Error Resume Next
  objNetwork.MapNetworkDrive "Z:", "\\crwin.crnet.org\dfs\bus\dept\bdu"
If Err.Number <> 0 Then
    objNetwork.RemoveNetworkDrive "Z:", True, True
    objNetwork.MapNetworkDrive "Z:", "\\crwin.crnet.org\dfs\bus\dept\bdu"
  End If
End If

If IsMember(objUser, "FS-LEGAL") Then
  On Error Resume Next
  objNetwork.MapNetworkDrive "F:", "\\crwin.crnet.org\dfs\bus\Data\CR-UK\EX\LEGAL\LEGAL"
  If Err.Number <> 0 Then
    objNetwork.RemoveNetworkDrive "F:", True, True
    objNetwork.MapNetworkDrive "F:", "\\crwin.crnet.org\dfs\bus\Data\CR-UK\EX\LEGAL\LEGAL"
  End If
End If


If IsMember(objUser, "CRT BM") Then
  On Error Resume Next
  objNetwork.MapNetworkDrive "V:", "\\crwin.crnet.org\dfs\bus\Data\CR-UK\RS\Scientific\Scientific\Sci Dept Shared Files\FUNDING COMMITTEES\Funding Committee Folders\DC\Discovery Committee (DC)"
If Err.Number <> 0 Then
    objNetwork.RemoveNetworkDrive "V:", True, True
    objNetwork.MapNetworkDrive "V:", "\\crwin.crnet.org\dfs\bus\Data\CR-UK\RS\Scientific\Scientific\Sci Dept Shared Files\FUNDING COMMITTEES\Funding Committee Folders\DC\Discovery Committee (DC)"
  End If
End If

' Display an informational message window showing network drive mappings which then autmatically closes after 5 seconds
call DisplayMappings

' Use the NameTranslate object to convert the NT name of the computer to
' the Distinguished name required for the LDAP provider. Computer names
' must end with "$".
strComputer = objNetwork.computerName
objTrans.Set ADS_NAME_TYPE_NT4, strNetBIOSDomain _
  & "\" & strComputer & "$"
strComputerDN = objTrans.Get(ADS_NAME_TYPE_1779)

' Bind to the computer object in Active Directory with the LDAP
' provider.
Set objComputer = GetObject("LDAP://" & strComputerDN)

Function IsMember(objADObject, strGroupNTName)
' Function to test for group membership.
' objADObject is a user or computer object.
' strGroupNTName is the NT name (sAMAccountName) of the group to test.
' objGroupList is a dictionary object, with global scope.
' Returns True if the user or computer is a member of the group.
' Subroutine LoadGroups is called once for each different objADObject.

' The first time IsMember is called, setup the dictionary object
' and objects required for ADO.
  If IsEmpty(objGroupList) Then
    Set objGroupList = CreateObject("Scripting.Dictionary")
    objGroupList.CompareMode = vbTextCompare

    Set objCommand = CreateObject("ADODB.Command")
    Set objConnection = CreateObject("ADODB.Connection")
    objConnection.Provider = "ADsDSOObject"
    objConnection.Open "Active Directory Provider"
    objCommand.ActiveConnection = objConnection

    Set objRootDSE = GetObject("LDAP://RootDSE")
    strDNSDomain = objRootDSE.Get("defaultNamingContext")

    objCommand.Properties("Page Size") = 100
    objCommand.Properties("Timeout") = 30
    objCommand.Properties("Cache Results") = False

    ' Search entire domain.
    strBase = "<LDAP://" & strDNSDomain & ">"
    ' Retrieve NT name of each group.
    strAttributes = "sAMAccountName"

    ' Load group memberships for this user or computer into dictionary
    ' object.
    Call LoadGroups(objADObject)
  End If
  If Not objGroupList.Exists(objADObject.sAMAccountName & "\") Then
    ' Dictionary object established, but group memberships for this
    ' user or computer must be added.
    Call LoadGroups(objADObject)
  End If
  ' Return True if this user or computer is a member of the group.
  IsMember = objGroupList.Exists(objADObject.sAMAccountName & "\" _
    & strGroupNTName)
End Function

Sub LoadGroups(objADObject)
' Subroutine to populate dictionary object with group memberships.
' objGroupList is a dictionary object, with global scope. It keeps track
' of group memberships for each user or computer separately. ADO is used
' to retrieve the name of the group corresponding to each objectSid in
' the tokenGroup array. Based on an idea by Joe Kaplan.

  Dim arrbytGroups, k, strFilter, objRecordSet, strGroupName, strQuery

  ' Add user name to dictionary object, so LoadGroups need only be
  ' called once for each user or computer.
  objGroupList(objADObject.sAMAccountName & "\") = True

  ' Retrieve tokenGroups array, a calculated attribute.
  objADObject.GetInfoEx Array("tokenGroups"), 0
  arrbytGroups = objADObject.Get("tokenGroups")

  ' Create a filter to search for groups with objectSid equal to each
  ' value in tokenGroups array.
  strFilter = "(|"
  If TypeName(arrbytGroups) = "Byte()" Then
    ' tokenGroups has one entry.
    strFilter = strFilter & "(objectSid=" _
      & OctetToHexStr(arrbytGroups) & ")"
  ElseIf UBound(arrbytGroups) > -1 Then
    ' TokenGroups is an array of two or more objectSid's.
    For k = 0 To UBound(arrbytGroups)
      strFilter = strFilter & "(objectSid=" _
        & OctetToHexStr(arrbytGroups(k)) & ")"
    Next
  Else
    ' tokenGroups has no objectSid's.
    Exit Sub
  End If
  strFilter = strFilter & ")"

  ' Use ADO to search for groups whose objectSid matches any of the
  ' tokenGroups values for this user or computer.
  strQuery = strBase & ";" & strFilter & ";" _
    & strAttributes & ";subtree"
  objCommand.CommandText = strQuery
  Set objRecordSet = objCommand.Execute

  ' Enumerate groups and add NT name to dictionary object.
  Do Until objRecordSet.EOF
    strGroupName = objRecordSet.Fields("sAMAccountName")
    objGroupList(objADObject.sAMAccountName & "\" _
      & strGroupName) = True
    objRecordSet.MoveNext
  Loop

  Set objRecordSet = Nothing
End Sub

' DisplayMappings sub routine to display an informational message window showing network drive mappings which then autmatically closes after 5 seconds
Sub DisplayMappings()

On Error Resume Next

' Declare variables 
Dim sTime, sDate, sMessage, sAdsPath, GreetingTime, oUser

' Set the time and date from the computer
    sTime = Hour(Now)
    sDate = Now

' Using the 24 hour clock determine morning afternoon or evening
    If sTime <= 11 Then
        GreetingTime = "morning"
    ElseIf sTime <= 17 Then
        GreetingTime = "afternoon"
    Else
        GreetingTime = "evening"
    End If


' Set DriveCollection variable to allow enumeration of network drive letters
     Set DriveCollection = objNetwork.EnumNetworkDrives


' Bind objshell variable WSH shell to allow exposure of the message window popup property
'     Set objShell = CreateObject("Wscript.Shell") 


' Create message for top of popup window including users first name and login id base on the the time of day
  MsgString = "Good " & GreetingTime & " " & objuser.firstname & vbcrlf & "You are logged in as " & strNTName & " and have access to the following" & vbcrlf & "CR-UK network drive connections: " & vbCRLF
    
    
' List the network drives connected on the users workstaton and append it to the above message - create drivedisplay for log file
     For i = 0 To DriveCollection.Count - 1 Step 2
          MsgString = MsgString & vbCRLF & DriveCollection(i) & Chr(9) & DriveCollection(i + 1) 
	drivedisplay = drivedisplay & vbCrLf & DriveCollection(i) & Chr(9) & DriveCollection(i + 1)
     Next
 
' Use objshell.popup to display the entire message and then timeout after 5 seconds
DisplayMessage = objshell.popup ( msgstring & vbCRLF & vbCRLF & "This information box will automatically close after 5 seconds", 5, "Cancer Research UK.")

' Bind to wMI so that the workstation IP address can be obtained
Set objWMIService = GetObject("winmgmts:")
Set colNicConfig = objWMIService.ExecQuery("SELECT * FROM " & _
 "Win32_NetworkAdapterConfiguration WHERE IPEnabled = True")
For Each objNicConfig In colNicConfig
  
  If Not IsNull(objNicConfig.IPAddress) Then
    strIPAddresses = Join(objNicConfig.IPAddress)
  End If

Next

today_date()

dateinfo = dateinfo & Now


' Create binding to allow reading the text file
Set objFSO = CreateObject ("Scripting.FileSystemObject")

If objFSO.FileExists ("\\crwin.crnet.org\dfs\apps\LoginLogs\"&thisday&"-"&strntname&".txt") Then

Set objfile= objFSO.OpenTextFile ("\\crwin.crnet.org\dfs\apps\LoginLogs\"&thisday&"-"&strntname&".txt", 8)
objfile.writeline vbCRLF & dateinfo & " " & strntname & drivedisplay & vbCRLF & "IP Address: " & strIPAddresses
objfile.close

Else
' Create the AD info text file
Set objfile = objFSO.CreateTextFile ("\\crwin.crnet.org\dfs\apps\LoginLogs\"&thisday&"-"&strntname&".txt")
objfile.writeline vbCRLF & dateinfo & " " & strntname & drivedisplay & vbCRLF & "IP Address: " & strIPAddresses
objfile.close

End If


' Log the Date, Username, IP Address, Computername into SQL Server
Set colCompSys = objWMIService.ExecQuery("SELECT * FROM Win32_ComputerSystem")

For Each objCompSys In colCompSys
  
  If Not IsNull(objCompSys.Name) Then
    strComputerName = objCompSys.Name
  End If

Next

isodate=Year(Date) & "-" & Right("0" & Month(Date),2) & "-" & Right("0" & Day(Date),2) & " " & Right(Now, 8)

' set objConnection = CreateObject("ADODB.Connection")

' objConnection.Open "Provider=SQLOLEDB.1;Integrated Security=SSPI;Persist Security Info=False;Initial ' Catalog=SystemsDB;Data Source=UK-LIF-LSQL06\SYSTEMS;Application Name=Login Script"

' objConnection.Execute "CreateLoginLog '" & isodate & "', '" & strntname & "', '" & strIPAddresses & "', '" ' & ' strComputerName & "', '" & drivedisplay & "'"

' objConnection.Close 

' set objConnection = Nothing

End Sub
 
Function OctetToHexStr(arrbytOctet)
' Function to convert OctetString (byte array) to Hex string,
' with bytes delimited by \ for an ADO filter.

  Dim k
  OctetToHexStr = ""
  For k = 1 To Lenb(arrbytOctet)
    OctetToHexStr = OctetToHexStr & "\" _
      & Right("0" & Hex(Ascb(Midb(arrbytOctet, k, 1))), 2)
  Next
End Function

' ### This funtion gets the date in format dd-mm-yy ###
Function Today_Date()

thisday=Right("0" & Day(Date),2) & "-" &  Right("0" & Month(Date),2) & "-" & Right(Year(Date),2)  

End Function
' ***************************************************************


'Create bindings etc for deleting old drive mapping log files.
'    iDaysOld = 10
'    Set objFSO = CreateObject("Scripting.FileSystemObject")
'    sDirectoryPath = "\\venus\LoginScriptLogs$"
'    Set oFolder = objFSO.GetFolder(sDirectoryPath)
'    Set oFileCollection = oFolder.Files

'If drive mapping log file is older than 5 days, then delete it.
'    For Each oFile in oFileCollection
'        If oFile.DateLastModified < (Date() - iDaysOld) Then
'            oFile.Delete(True)
'        End If
'    Next
